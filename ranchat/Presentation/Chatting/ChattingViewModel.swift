//
//  ChattingViewModel.swift
//  ranchat
//

import SwiftUI

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
            showNetworkErrorDialog = true
            return
        }

        isLoading = true
        do {
            let roomDetail = try await getRoomDetailUseCase.execute(userId: userId, roomId: roomId)
            self.roomDetailData = roomDetail
            self.isRoomDetailDataLoaded = true
        } catch {
            Logger.shared.log(className, #function, "Failed to get room detail data: \(error.localizedDescription)", .error)
            showNetworkErrorDialog = true
        }
        isLoading = false
    }

    func getMessageList() async {
        guard let roomId = idHelper?.getRoomId() else {
            Logger.shared.log(className, #function, "roomId is nil", .error)
            showNetworkErrorDialog = true
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
        } catch {
            Logger.shared.log(className, #function, "Failed to get message list: \(error.localizedDescription)", .error)
            showNetworkErrorDialog = true
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
        } catch {
            Logger.shared.log(className, #function, "Failed to fetch message list: \(error.localizedDescription)", .error)
            currentPage -= 1
            showNetworkErrorDialog = true
        }
    }

    func sendMessage() {
        let message = inputText
        if message.isEmpty { return }

        if !(networkMonitor?.isConnected ?? false) {
            showNetworkErrorDialog = true
            return
        }

        guard let webSocketService,
              let userId = idHelper?.getUserId(),
              let roomId = idHelper?.getRoomId() else {
            Logger.shared.log(className, #function, "webSocketService or idHelper is nil", .error)
            showNetworkErrorDialog = true
            return
        }

        do {
            try webSocketService.sendMessage(userId: userId, roomId: roomId, content: message)
            inputText = ""
        } catch {
            Logger.shared.log(className, #function, "Failed to send message: \(error.localizedDescription)", .error)
            showNetworkErrorDialog = true
        }
    }

    func reportUser() async {
        guard let userId = idHelper?.getUserId(),
              let roomId = idHelper?.getRoomId() else {
            Logger.shared.log(className, #function, "userId or roomId is nil", .error)
            showNetworkErrorDialog = true
            return
        }

        guard let reportedUserId = roomDetailData?.participants.first(where: { $0.userId != userId })?.userId else {
            Logger.shared.log(className, #function, "reportedUserId is nil", .error)
            showNetworkErrorDialog = true
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
        } catch {
            Logger.shared.log(className, #function, "Failed to report user: \(error.localizedDescription)", .error)
            showNetworkErrorDialog = true
        }
        isLoading = false
    }

    func exitRoom() async {
        if !(networkMonitor?.isConnected ?? false) {
            showNetworkErrorDialog = true
            return
        }

        isLoading = true

        guard let idHelper,
              let roomId = idHelper.getRoomId(),
              let userId = idHelper.getUserId(),
              let webSocketService else {
            Logger.shared.log(className, #function, "idHelper or webSocketService is nil", .error)
            showNetworkErrorDialog = true
            isLoading = false
            return
        }

        do {
            try webSocketService.exitRoom(userId: userId, roomId: roomId)
            (dismiss ?? {})()
        } catch {
            Logger.shared.log(className, #function, "Failed to exit room: \(error.localizedDescription)", .error)
            showNetworkErrorDialog = true
        }

        isLoading = false
    }

    func tempExit() {
        if !(networkMonitor?.isConnected ?? false) {
            showNetworkErrorDialog = true
            return
        }

        do {
            try unsubscribeMessage()
            (dismiss ?? {})()
        } catch {
            Logger.shared.log(className, #function, "Failed to unsubscribe message: \(error.localizedDescription)")
            showNetworkErrorDialog = true
        }
    }

    func unsubscribeMessage() throws {
        guard let idHelper,
              let roomId = idHelper.getRoomId(),
              let webSocketService else {
            Logger.shared.log(className, #function, "idHelper or webSocketService is nil")
            showNetworkErrorDialog = true
            throw IdHelperError.nilError
        }

        do {
            try webSocketService.unsubscribeMessages(roomId: roomId)
        } catch {
            Logger.shared.log(className, #function, "Failed to unsubscribe from receive message: \(error.localizedDescription)")
            showNetworkErrorDialog = true
            throw WebSocketHelperError.connectError
        }
    }

    func activateParticipant() {
        guard let webSocketService,
              let userId = idHelper?.getUserId(),
              let roomId = idHelper?.getRoomId() else {
            Logger.shared.log(className, #function, "webSocketService or idHelper is nil")
            showNetworkErrorDialog = true
            return
        }

        do {
            try webSocketService.activateParticipant(userId: userId, roomId: roomId)
        } catch {
            Logger.shared.log(className, #function, "Failed to activate participant: \(error.localizedDescription)")
            showNetworkErrorDialog = true
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
}
