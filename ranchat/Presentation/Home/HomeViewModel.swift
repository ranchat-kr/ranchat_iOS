//
//  HomeViewModel.swift
//  ranchat
//

import UUIDV7
import SwiftUI

@Observable
class HomeViewModel {
    let className = "HomeViewModel"

    var showNetworkErrorDialog = false
    var isLoading = false
    var isMatching = false
    var isRoomExist = false
    var isInitialized = false
    var isMatchSuccess = false

    var goToSetting = false
    var goToChat = false
    var goToRoomList = false

    var webSocketService: (any WebSocketService)?
    var idHelper: IdHelper?
    var networkMonitor: NetworkMonitor?

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

    func setup(webSocketService: any WebSocketService, idHelper: IdHelper, networkMonitor: NetworkMonitor) {
        self.webSocketService = webSocketService
        self.idHelper = idHelper
        self.networkMonitor = networkMonitor

        webSocketService.setOnMatchingSuccess { [weak self] roomId in
            self?.idHelper?.setRoomId(roomId)
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
        guard let webSocketService, let idHelper else {
            Logger.shared.log(className, #function, "webSocketService or idHelper is nil", .error)
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

                if let userId = KeychainHelper.shared.getUserId() {
                    idHelper.setUserId(userId)
                } else {
                    let uuid = UUID.uuidV7String()
                    KeychainHelper.shared.saveUserId(uuid)
                    idHelper.setUserId(uuid)
                    try await createUserUseCase.execute(id: uuid, name: getRandomNickname())
                }

                guard let userId = idHelper.getUserId() else {
                    throw ApiHelperError.nilError
                }
                try webSocketService.connect(userId: userId)
                await checkRoomExist()
                self.isInitialized = true
            } catch {
                showNetworkErrorDialog = true
                Logger.shared.log(className, #function, "Failed to set user: \(error.localizedDescription)", .error)
            }
            isLoading = false
        }
    }

    func successMatching() {
        isMatching = false

        if !(networkMonitor?.isConnected ?? false) {
            showNetworkErrorDialog = true
            return
        }

        guard let webSocketService,
              let userId = idHelper?.getUserId(),
              let roomId = idHelper?.getRoomId() else {
            Logger.shared.log(className, #function, "webSocketService or idHelper is nil")
            return
        }

        do {
            try webSocketService.cancelMatching(userId: userId)
            try webSocketService.enterRoom(userId: userId, roomId: roomId)
            isMatchSuccess = false
            navigateToChat()
        } catch {
            showNetworkErrorDialog = true
            Logger.shared.log(className, #function, "Failed to success matching: \(error.localizedDescription)", .error)
        }
    }

    func requestMatching() {
        if !(networkMonitor?.isConnected ?? false) {
            showNetworkErrorDialog = true
            return
        }

        isMatching = true

        guard let webSocketService, let userId = idHelper?.getUserId() else {
            Logger.shared.log(className, #function, "webSocketService or idHelper is nil", .error)
            isMatching = false
            return
        }

        do {
            try webSocketService.requestMatching(userId: userId)
            checkMatching()
        } catch {
            isMatching = false
            showNetworkErrorDialog = true
            Logger.shared.log(className, #function, "Failed to request matching: \(error.localizedDescription)", .error)
        }
    }

    func checkMatching() {
        guard let webSocketService, let idHelper else {
            Logger.shared.log(className, #function, "webSocketService or idHelper is nil", .error)
            return
        }

        Task {
            do {
                try await Task.sleep(for: .seconds(8))

                if !isMatching { return }

                isMatching = false

                if !(networkMonitor?.isConnected ?? false) {
                    showNetworkErrorDialog = true
                    return
                }

                guard let userId = idHelper.getUserId() else {
                    throw ApiHelperError.nilError
                }

                try webSocketService.cancelMatching(userId: userId)

                if !isMatchSuccess {
                    let roomId = try await createRoomUseCase.execute(userId: userId)
                    idHelper.setRoomId(roomId)
                }

                guard let roomId = idHelper.getRoomId() else {
                    throw ApiHelperError.nilError
                }

                try webSocketService.enterRoom(userId: userId, roomId: roomId)
                isMatchSuccess = false
                navigateToChat()
            } catch {
                isMatching = false
                showNetworkErrorDialog = true
                Logger.shared.log(className, #function, "Failed to check matching: \(error.localizedDescription)", .error)
            }
        }
    }

    func checkRoomExist() async {
        guard let userId = idHelper?.getUserId() else {
            Logger.shared.log(className, #function, "userId is nil", .error)
            return
        }

        isLoading = true
        do {
            self.isRoomExist = try await checkRoomExistUseCase.execute(userId: userId)
        } catch {
            showNetworkErrorDialog = true
            Logger.shared.log(className, #function, "Failed to check room exist: \(error.localizedDescription)", .error)
        }
        isLoading = false
    }

    func getRandomNickname() -> String {
        let frontNickname = [
            "행복한", "빛나는", "빠른", "작은", "푸른", "깊은", "웃는", "고요한", "따뜻한", "하얀", "즐거운", "맑은", "예쁜", "강한", "조용한", "푸른", "따뜻한", "밝은", "신비한", "높은",
        ]
        let backNickname = [
            "고양이", "별", "바람", "새", "하늘", "바다", "사람", "숲", "햇살", "눈", "여행", "강", "꽃", "용", "밤", "나무", "마음", "햇빛", "섬", "산",
        ]

        return (frontNickname.randomElement() ?? "") + (backNickname.randomElement() ?? "")
    }
}
