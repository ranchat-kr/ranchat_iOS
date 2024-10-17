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
    
    func reportUser() {
        isLoading = true
        
        
        
        isLoading = false
    }
    
    func exitRoom() async {
        isLoading = true
        
        
        
        isLoading = false
    }
}
