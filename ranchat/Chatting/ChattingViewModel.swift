//
//  ChattingViewModel.swift
//  ranchat
//
//  Created by 김견 on 10/9/24.
//

import Foundation

@Observable
class ChattingViewModel {
    let className = "ChattingViewModel"
    
    var messageDataList: [MessageData] = []
    var isLoading: Bool = false
    
    var inputText: String = ""
    var roomDetailData: RoomDetailData?
    
    var showReportDialog: Bool = false
    var showExitDialog: Bool = false
    var showNetworkErrorAlert: Bool = false
    
    var selectedReason: String?
    var reportText: String = ""
    
    var currentPage: Int = 0
    let pageSize: Int = 50
    var totalCount: Int = 0
    
    var webSocketHelper: WebSocketHelper?
    var idHelper: IdHelper?
    var dismiss: (() -> Void)?
    var networkMonitor: NetworkMonitor?
    
    func setHelper(_ webSocketHelper: WebSocketHelper,_ idHelper: IdHelper) {
        self.webSocketHelper = webSocketHelper
        self.idHelper = idHelper
    }
    
    func setDismiss(_ dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
    }
    
    func setNetworkMonitor(_ networkMonitor: NetworkMonitor) {
        self.networkMonitor = networkMonitor
    }
    
    func addMessage(messageData: MessageData) {
        messageDataList.insert(messageData, at: 0)
        //messageDataList.append(messageData)
    }
    
    func tempExit() {
        if !(networkMonitor?.isConnected ?? false) {
            showNetworkErrorAlert = true
            return
        }
        
        do {
            try unSubscribeMessage()
            (dismiss ?? {})()
        } catch {
            Logger.shared.log(self.className, #function, "Failed to unSubscribe message: \(error.localizedDescription)")
            showNetworkErrorAlert = true
        }
    }
    
    //MARK: - Require Network
    func getRoomDetailData() async {
        isLoading = true
        
        do {
            let roomDetailData = try await ApiHelper.shared.getRoomDetail()
            self.roomDetailData = roomDetailData
        } catch {
            Logger.shared.log(self.className, #function, "Failed to get room detail data: \(error.localizedDescription)", .error)
            showNetworkErrorAlert = true
        }
        
        isLoading = false
    }
    
    func getMessageList() async {
        isLoading = true
        
        do {
            let messagesListResponseData = try await ApiHelper.shared.getMessages(page: currentPage, size: pageSize * 2)
            self.currentPage += 1
            self.totalCount = messagesListResponseData.totalCount
            self.messageDataList.removeAll()
            self.messageDataList += messagesListResponseData.items
        } catch {
            Logger.shared.log(self.className, #function, "Failed to get message list: \(error.localizedDescription)", .error)
            showNetworkErrorAlert = true
        }
        
        isLoading = false
    }
    
    func fetchMessageList() async {
        do {
            if messageDataList.count >= (currentPage + 1) * pageSize || messageDataList.count < self.totalCount {
                currentPage += 1
                let messagesListResponseData = try await ApiHelper.shared.getMessages(page: currentPage, size: pageSize)
                self.messageDataList += messagesListResponseData.items
            }
        } catch {
            Logger.shared.log(self.className, #function, "Failed to fetch message list: \(error.localizedDescription)", .error)
            currentPage -= 1
            showNetworkErrorAlert = true
        }
    }
    
    func sendMessage() {
        let message = inputText
        if message.isEmpty { return }
        
        if !(networkMonitor?.isConnected ?? false) {
            showNetworkErrorAlert = true
            return
        }
        
        do {
            if let webSocketHelper {
                try webSocketHelper.sendMessage(message)
                inputText = ""
            } else {
                Logger.shared.log(self.className, #function, "webSocketHelper is nil", .error)
                showNetworkErrorAlert = true
            }
        } catch {
            Logger.shared.log(self.className, #function, "Failed to send message: \(error.localizedDescription)", .error)
            showNetworkErrorAlert = true
        }
    }
    
    func reportUser() async {
        isLoading = true
        
        guard let reportedUserId = roomDetailData?.participants.first(where: { $0.userId != idHelper?.getUserId() })?.userId else {
            Logger.shared.log(self.className, #function, "reportedUserId is nil", .error)
            
            showNetworkErrorAlert = true
            return
        }
        
        let reportType = getReportType(reason: selectedReason)
        
        do {
            try await ApiHelper.shared.reportUser(
                reportedUserId: reportedUserId,
                reportReason: reportText,
                reportType: reportType
            )
        } catch {
            Logger.shared.log(self.className, #function, "Failed to report user: \(error.localizedDescription)", .error)
            showNetworkErrorAlert = true
        }
        
        isLoading = false
    }
    
    func exitRoom() async {
        if !(networkMonitor?.isConnected ?? false) {
            showNetworkErrorAlert = true
            return
        }
        
        isLoading = true
        
        if let idHelper, let roomId = idHelper.getRoomId(), let webSocketHelper {
            do {
                try webSocketHelper.exitRoom(roomId: roomId)
                (dismiss ?? {})()
            } catch {
                Logger.shared.log(self.className, #function, "Failed to exit room: \(error.localizedDescription)", .error)
                showNetworkErrorAlert = true
            }
        } else {
            Logger.shared.log(self.className, #function, "idHelper or webSocketHelper is nil", .error)
            showNetworkErrorAlert = true
        }
        
        isLoading = false
    }
    
    func unSubscribeMessage() throws {
        if let idHelper, let roomId = idHelper.getRoomId(), let webSocketHelper {
            do {
                try webSocketHelper.unsubscribeFromRecieveMessage(roomId: roomId)
            } catch {
                Logger.shared.log(self.className, #function, "Failed to unsubscribe from recieve message: \(error.localizedDescription)")
                showNetworkErrorAlert = true
                throw WebSocketHelperError.connectError
            }
        } else {
            Logger.shared.log(self.className, #function, "idHelper or webSocketHelper is nil")
            showNetworkErrorAlert = true
            throw IdHelperError.nilError
        }
    }
    
    //MARK: - ETC
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
