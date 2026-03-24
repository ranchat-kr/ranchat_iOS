//
//  HomeViewModel.swift
//  ranchat
//

import UUIDV7
import SwiftUI

@MainActor
@Observable
class HomeViewModel {
    let className = "HomeViewModel"

    var showNetworkErrorDialog = false
    var networkErrorTitle = "오류"
    var networkErrorContent = "알 수 없는 오류가 발생했습니다."
    var isLoading = false
    var isMatching = false
    var isRoomExist = false
    var isInitialized = false
    var isMatchSuccess = false
    var matchedRoomId: String = ""

    var goToSetting = false
    var goToChat = false
    var goToRoomList = false

    var webSocketService: (any WebSocketService)?
    var networkMonitor: (any NetworkMonitorProtocol)?

    private var createUserUseCase: any CreateUserUseCase
    private var checkRoomExistUseCase: any CheckRoomExistUseCase
    private var createRoomUseCase: any CreateRoomUseCase

    init(
        createUserUseCase: any CreateUserUseCase = DefaultCreateUserUseCase(),
        checkRoomExistUseCase: any CheckRoomExistUseCase = DefaultCheckRoomExistUseCase(),
        createRoomUseCase: any CreateRoomUseCase = DefaultCreateRoomUseCase()
    ) {
        self.createUserUseCase = createUserUseCase
        self.checkRoomExistUseCase = checkRoomExistUseCase
        self.createRoomUseCase = createRoomUseCase
    }

    func setup(webSocketService: any WebSocketService, networkMonitor: any NetworkMonitorProtocol) {
        self.webSocketService = webSocketService
        self.networkMonitor = networkMonitor

        webSocketService.setOnMatchingSuccess { [weak self] roomId in
            self?.matchedRoomId = roomId
            self?.isMatchSuccess = true
        }
    }

    func navigateToChat() {
        goToChat = true
    }

    func navigateToRoomList() {
        goToRoomList = true
    }

    func navigateToSetting() {
        goToSetting = true
    }

    func setUser() {
        guard !isLoading else { return }
        guard let webSocketService else {
            Logger.shared.log(className, #function, "webSocketService is nil", .error)
            return
        }

        isLoading = true

        Task {
            do {
                // AppStorage → Keychain 마이그레이션
                @AppStorage("user_id") var legacyUserId: String?
                if let legacy = legacyUserId, KeychainHelper.shared.getUserId() == nil {
                    KeychainHelper.shared.saveUserId(legacy)
                    legacyUserId = nil
                }

                if KeychainHelper.shared.getUserId() == nil {
                    let uuid = UUID.uuidV7String()
                    KeychainHelper.shared.saveUserId(uuid)
                    try await createUserUseCase.execute(id: uuid, name: getRandomNickname())
                }

                guard let userId = KeychainHelper.shared.getUserId() else {
                    throw ApiHelperError.nilError
                }
                try webSocketService.connect(userId: userId)
                await checkRoomExist()
                self.isInitialized = true
            } catch let apiError as ApiHelperError {
                setError(apiError)
                Logger.shared.log(className, #function, "Failed to set user: \(apiError)", .error)
            } catch {
                setUnknownError()
                Logger.shared.log(className, #function, "Failed to set user: \(error.localizedDescription)", .error)
            }
            isLoading = false
        }
    }

    func successMatching() {
        isMatching = false

        if !(networkMonitor?.isConnected ?? false) {
            showNetworkUnavailableError()
            return
        }

        guard let webSocketService,
              let userId = KeychainHelper.shared.getUserId() else {
            Logger.shared.log(className, #function, "webSocketService or userId is nil")
            return
        }

        guard !matchedRoomId.isEmpty else {
            Logger.shared.log(className, #function, "matchedRoomId is empty", .error)
            return
        }

        do {
            try webSocketService.cancelMatching(userId: userId)
            try webSocketService.enterRoom(userId: userId, roomId: matchedRoomId)
            isMatchSuccess = false
            navigateToChat()
        } catch let apiError as ApiHelperError {
            setError(apiError)
            Logger.shared.log(className, #function, "Failed to success matching: \(apiError)", .error)
        } catch {
            setUnknownError()
            Logger.shared.log(className, #function, "Failed to success matching: \(error.localizedDescription)", .error)
        }
    }

    func requestMatching() {
        if !(networkMonitor?.isConnected ?? false) {
            showNetworkUnavailableError()
            return
        }

        isMatching = true

        guard let webSocketService, let userId = KeychainHelper.shared.getUserId() else {
            Logger.shared.log(className, #function, "webSocketService or userId is nil", .error)
            isMatching = false
            return
        }

        do {
            try webSocketService.requestMatching(userId: userId)
            checkMatching()
        } catch let apiError as ApiHelperError {
            isMatching = false
            setError(apiError)
            Logger.shared.log(className, #function, "Failed to request matching: \(apiError)", .error)
        } catch {
            isMatching = false
            setUnknownError()
            Logger.shared.log(className, #function, "Failed to request matching: \(error.localizedDescription)", .error)
        }
    }

    func checkMatching() {
        guard let webSocketService else {
            Logger.shared.log(className, #function, "webSocketService is nil", .error)
            return
        }

        Task {
            do {
                try await Task.sleep(for: .seconds(8))

                if !isMatching { return }

                isMatching = false

                if !(networkMonitor?.isConnected ?? false) {
                    showNetworkUnavailableError()
                    return
                }

                guard let userId = KeychainHelper.shared.getUserId() else {
                    throw ApiHelperError.nilError
                }

                try webSocketService.cancelMatching(userId: userId)

                if !isMatchSuccess {
                    let roomId = try await createRoomUseCase.execute(userId: userId)
                    matchedRoomId = roomId
                }

                guard !matchedRoomId.isEmpty else {
                    throw ApiHelperError.nilError
                }

                try webSocketService.enterRoom(userId: userId, roomId: matchedRoomId)
                isMatchSuccess = false
                navigateToChat()
            } catch let apiError as ApiHelperError {
                isMatching = false
                setError(apiError)
                Logger.shared.log(className, #function, "Failed to check matching: \(apiError)", .error)
            } catch {
                isMatching = false
                setUnknownError()
                Logger.shared.log(className, #function, "Failed to check matching: \(error.localizedDescription)", .error)
            }
        }
    }

    func checkRoomExist() async {
        guard let userId = KeychainHelper.shared.getUserId() else {
            Logger.shared.log(className, #function, "userId is nil", .error)
            return
        }

        do {
            self.isRoomExist = try await checkRoomExistUseCase.execute(userId: userId)
        } catch let apiError as ApiHelperError {
            setError(apiError)
            Logger.shared.log(className, #function, "Failed to check room exist: \(apiError)", .error)
        } catch {
            setUnknownError()
            Logger.shared.log(className, #function, "Failed to check room exist: \(error.localizedDescription)", .error)
        }
    }

    private func setError(_ error: ApiHelperError) {
        networkErrorTitle = error.dialogTitle
        networkErrorContent = error.dialogContent
        showNetworkErrorDialog = true
    }

    private func setUnknownError() {
        networkErrorTitle = "오류"
        networkErrorContent = "알 수 없는 오류가 발생했습니다."
        showNetworkErrorDialog = true
    }

    private func showNetworkUnavailableError() {
        networkErrorTitle = "네트워크 오류"
        networkErrorContent = "인터넷 연결을 확인해주세요."
        showNetworkErrorDialog = true
    }

    func getRandomNickname() -> String {
        let frontNickname = [
            "행복한", "빛나는", "빠른", "작은", "푸른", "깊은", "웃는", "고요한", "따뜻한", "하얀",
            "즐거운", "맑은", "예쁜", "강한", "조용한", "밝은", "신비한", "높은", "용감한", "귀여운",
        ]
        let backNickname = [
            "고양이", "별", "바람", "새", "하늘", "바다", "사람", "숲", "햇살", "눈",
            "여행", "강", "꽃", "용", "밤", "나무", "마음", "햇빛", "섬", "산",
        ]

        return (frontNickname.randomElement() ?? "") + (backNickname.randomElement() ?? "")
    }
}
