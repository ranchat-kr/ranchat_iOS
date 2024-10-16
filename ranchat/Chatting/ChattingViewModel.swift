//
//  ChattingViewModel.swift
//  ranchat
//
//  Created by 김견 on 10/9/24.
//

import Foundation

@Observable
class ChattingViewModel {
    var messageDataList: [MessageData] = []
    var isLoading: Bool = false
    
    var inputText: String = ""
    var roomDetailData: RoomDetailData?
    
    var showReportDialog: Bool = false
    var showExitDialog: Bool = false
    
    var selectedReason: String?
    var reportText: String = ""
    
    var currentPage: Int = 0
    let pageSize: Int = 50
    
    var webSocketHelper: WebSocketHelper?
    var idHelper: IdHelper?
    
    func setHelper(_ webSocketHelper: WebSocketHelper,_ idHelper: IdHelper) {
        self.webSocketHelper = webSocketHelper
        self.idHelper = idHelper
    }
    
    func addMessage(messageData: MessageData) {
        messageDataList.append(messageData)
    }
    
    //MARK: - Require Network
    func getRoomDetailData() async {
        isLoading = true
        
        do {
            let roomDetailData = try await ApiHelper.shared.getRoomDetail()
            self.roomDetailData = roomDetailData
        } catch {
            print("DEBUG: ChattingViewModel - getRoomDetailData - error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func getMessageList() async {
        isLoading = true
        
        do {
            let messageList = try await ApiHelper.shared.getMessages(page: currentPage, size: pageSize * 2)
            currentPage += 1
            self.messageDataList.removeAll()
            self.messageDataList = messageList
            print("messageList: \(messageList)")
        } catch {
            print("DEBUG: ChattingViewModel - getMessageList - error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func fetchMessageList() async {
        isLoading = true
        
        do {
            currentPage += 1
            let messageList = try await ApiHelper.shared.getMessages(page: currentPage, size: pageSize)
            self.messageDataList.append(contentsOf: messageList)
        } catch {
            print("DEBUG: ChattingViewModel - fetchMessageList - error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func sendMessage() {
        let message = inputText
        do {
            if let webSocketHelper {
                try webSocketHelper.sendMessage(message)
                inputText = ""
            } else {
                print("DEBUG: ChattingViewModel - sendMessage - webSocketHelper is nil")
            }
        } catch {
            print("DEBUG: ChattingViewModel - sendMessage - error: \(error.localizedDescription)")
        }
    }
    
    func reportUser() async {
        isLoading = true
        
        guard let reportedUserId = roomDetailData?.participants.first(where: { $0.userId != idHelper?.getUserId() })?.userId else {
            print("DEBUG: ChattingViewModel - reportUser - reportedUserId is nil")
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
            print("DEBUG: ChattingViewModel - reportUser - error: \(error.localizedDescription)")
        }
        
        
        isLoading = false
    }
    
    func exitRoom() async {
        isLoading = true
        
        if let idHelper, let roomId = idHelper.getRoomId(), let webSocketHelper {
            do {
                try webSocketHelper.exitRoom(roomId: roomId)
            } catch {
                print("DEBUG: ChattingViewModel.exitRoom() error: \(error.localizedDescription)")
            }
        } else {
            print("DEBUG: ChattingViewModel.exitRoom() idHelper or webSocketHelper is nil")
        }
        
        isLoading = false
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
