//
//  ChattingViewModel.swift
//  ranchat
//

import SwiftUI

@MainActor
@Observable
class ChattingViewModel {
    let className = "ChattingViewModel"

    var messageDataList: [Message] = []

    var isLoading: Bool = false
    var isRoomDetailDataLoaded: Bool = false
    var isMessageDataListLoaded: Bool = false

    var inputText: String = ""
    var roomDetailData: RoomDetail?

    var showReportDialog: Bool = false
    var showExitDialog: Bool = false
    var showNetworkErrorDialog: Bool = false
    var networkErrorTitle: String = "오류"
    var networkErrorContent: String = "알 수 없는 오류가 발생했습니다."

    var selectedReason: String?
    var reportText: String = ""

    var currentPage: Int = 0
    let pageSize: Int = 50
    var totalCount: Int = 0

    var webSocketService: (any WebSocketService)?
    var idHelper: IdHelper?
    var dismiss: (() -> Void)?
    var networkMonitor: NetworkMonitor?

    private var getRoomDetailUseCase: any GetRoomDetailUseCase
    private var getMessagesUseCase: any GetMessagesUseCase
    private var reportUserUseCase: any ReportUserUseCase

    init(
        getRoomDetailUseCase: any GetRoomDetailUseCase = DefaultGetRoomDetailUseCase(),
        getMessagesUseCase: any GetMessagesUseCase = DefaultGetMessagesUseCase(),
        reportUserUseCase: any ReportUserUseCase = DefaultReportUserUseCase()
    ) {
        self.getRoomDetailUseCase = getRoomDetailUseCase
        self.getMessagesUseCase = getMessagesUseCase
        self.reportUserUseCase = reportUserUseCase
    }

    func setup(webSocketService: any WebSocketService, idHelper: IdHelper, networkMonitor: NetworkMonitor) {
        self.webSocketService = webSocketService
        self.idHelper = idHelper
        self.networkMonitor = networkMonitor

        webSocketService.setOnMessageReceived { [weak self] message in
            self?.messageDataList.insert(message, at: 0)
        }
    }

    func setDismiss(_ dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
    }

    // MARK: - Require Network

    func getRoomDetailData() async {
        guard let userId = idHelper?.getUserId(), let roomId = idHelper?.getRoomId() else {
            Logger.shared.log(className, #function, "userId or roomId is nil", .error)
            setError(.nilError)
            return
        }

        isLoading = true
        do {
            let roomDetail = try await getRoomDetailUseCase.execute(userId: userId, roomId: roomId)
            self.roomDetailData = roomDetail
            self.isRoomDetailDataLoaded = true
        } catch let apiError as ApiHelperError {
            Logger.shared.log(className, #function, "Failed to get room detail data: \(apiError)", .error)
            setError(apiError)
        } catch {
            Logger.shared.log(className, #function, "Failed to get room detail data: \(error.localizedDescription)", .error)
            setUnknownError()
        }
        isLoading = false
    }

    func getMessageList() async {
        guard let roomId = idHelper?.getRoomId() else {
            Logger.shared.log(className, #function, "roomId is nil", .error)
            setError(.nilError)
            return
        }

        isLoading = true
        do {
            let messagePage = try await getMessagesUseCase.execute(roomId: roomId, page: currentPage, size: pageSize * 2)
            self.currentPage += 1
            self.totalCount = messagePage.totalCount
            self.messageDataList.removeAll()
            self.messageDataList += messagePage.items
            self.isMessageDataListLoaded = true
        } catch let apiError as ApiHelperError {
            Logger.shared.log(className, #function, "Failed to get message list: \(apiError)", .error)
            setError(apiError)
        } catch {
            Logger.shared.log(className, #function, "Failed to get message list: \(error.localizedDescription)", .error)
            setUnknownError()
        }
        isLoading = false
    }

    func fetchMessageList() async {
        guard let roomId = idHelper?.getRoomId() else {
            Logger.shared.log(className, #function, "roomId is nil", .error)
            return
        }

        do {
            if messageDataList.count >= (currentPage + 1) * pageSize || messageDataList.count < self.totalCount {
                currentPage += 1
                let messagePage = try await getMessagesUseCase.execute(roomId: roomId, page: currentPage, size: pageSize)
                self.messageDataList += messagePage.items
            }
        } catch let apiError as ApiHelperError {
            Logger.shared.log(className, #function, "Failed to fetch message list: \(apiError)", .error)
            currentPage -= 1
            setError(apiError)
        } catch {
            Logger.shared.log(className, #function, "Failed to fetch message list: \(error.localizedDescription)", .error)
            currentPage -= 1
            setUnknownError()
        }
    }

    func sendMessage() {
        let message = inputText
        if message.isEmpty { return }

        if !(networkMonitor?.isConnected ?? false) {
            networkErrorTitle = "네트워크 오류"
            networkErrorContent = "인터넷 연결을 확인해주세요."
            showNetworkErrorDialog = true
            return
        }

        guard let webSocketService,
              let userId = idHelper?.getUserId(),
              let roomId = idHelper?.getRoomId() else {
            Logger.shared.log(className, #function, "webSocketService or idHelper is nil", .error)
            setError(.nilError)
            return
        }

        do {
            try webSocketService.sendMessage(userId: userId, roomId: roomId, content: message)
            inputText = ""
        } catch {
            Logger.shared.log(className, #function, "Failed to send message: \(error.localizedDescription)", .error)
            setUnknownError()
        }
    }

    func reportUser() async {
        guard let userId = idHelper?.getUserId(),
              let roomId = idHelper?.getRoomId() else {
            Logger.shared.log(className, #function, "userId or roomId is nil", .error)
            setError(.nilError)
            return
        }

        guard let reportedUserId = roomDetailData?.participants.first(where: { $0.userId != userId })?.userId else {
            Logger.shared.log(className, #function, "reportedUserId is nil", .error)
            setError(.nilError)
            return
        }

        isLoading = true
        let reportType = getReportType(reason: selectedReason)
        do {
            try await reportUserUseCase.execute(
                roomId: roomId,
                reporterId: userId,
                reportedUserId: reportedUserId,
                reportType: reportType,
                reportReason: reportText
            )
        } catch let apiError as ApiHelperError {
            Logger.shared.log(className, #function, "Failed to report user: \(apiError)", .error)
            setError(apiError)
        } catch {
            Logger.shared.log(className, #function, "Failed to report user: \(error.localizedDescription)", .error)
            setUnknownError()
        }
        isLoading = false
    }

    func exitRoom() async {
        if !(networkMonitor?.isConnected ?? false) {
            networkErrorTitle = "네트워크 오류"
            networkErrorContent = "인터넷 연결을 확인해주세요."
            showNetworkErrorDialog = true
            return
        }

        isLoading = true

        guard let idHelper,
              let roomId = idHelper.getRoomId(),
              let userId = idHelper.getUserId(),
              let webSocketService else {
            Logger.shared.log(className, #function, "idHelper or webSocketService is nil", .error)
            setError(.nilError)
            isLoading = false
            return
        }

        do {
            try webSocketService.exitRoom(userId: userId, roomId: roomId)
            (dismiss ?? {})()
        } catch {
            Logger.shared.log(className, #function, "Failed to exit room: \(error.localizedDescription)", .error)
            setUnknownError()
        }

        isLoading = false
    }

    func tempExit() {
        if !(networkMonitor?.isConnected ?? false) {
            networkErrorTitle = "네트워크 오류"
            networkErrorContent = "인터넷 연결을 확인해주세요."
            showNetworkErrorDialog = true
            return
        }

        do {
            try unsubscribeMessage()
            (dismiss ?? {})()
        } catch {
            Logger.shared.log(className, #function, "Failed to unsubscribe message: \(error.localizedDescription)")
            setUnknownError()
        }
    }

    func unsubscribeMessage() throws {
        guard let idHelper,
              let roomId = idHelper.getRoomId(),
              let webSocketService else {
            Logger.shared.log(className, #function, "idHelper or webSocketService is nil")
            setError(.nilError)
            throw IdHelperError.nilError
        }

        do {
            try webSocketService.unsubscribeMessages(roomId: roomId)
        } catch {
            Logger.shared.log(className, #function, "Failed to unsubscribe from receive message: \(error.localizedDescription)")
            setUnknownError()
            throw WebSocketHelperError.connectError
        }
    }

    func activateParticipant() {
        guard let webSocketService,
              let userId = idHelper?.getUserId(),
              let roomId = idHelper?.getRoomId() else {
            Logger.shared.log(className, #function, "webSocketService or idHelper is nil")
            return
        }

        do {
            try webSocketService.activateParticipant(userId: userId, roomId: roomId)
        } catch {
            Logger.shared.log(className, #function, "Failed to activate participant: \(error.localizedDescription)")
        }
    }

    // MARK: - ETC

    func getReportType(reason: String?) -> String {
        switch reason {
        case "스팸":
            return "SPAM"
        case "욕설 및 비방":
            return "HARASSMENT"
        case "광고":
            return "ADVERTISEMENT"
        case "허위 정보":
            return "MISINFORMATION"
        case "저작권 침해":
            return "COPYRIGHT_INFRINGEMENT"
        case "기타":
            return "ETC"
        default:
            return ""
        }
    }

    // MARK: - Private

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
}
