//
//  WebSocketHelper.swift
//  ranchat
//
//  Created by 김견 on 9/29/24.
//

import SwiftUI
import StompClientLib

enum WebSocketHelperError: Error {
    case invalidURLError
    case networkError(String)
    case responseDataError
    case connectError
    case nilError
}

@Observable
class WebSocketHelper {
    private let socketURL = "wss://\(DefaultData.domain)/endpoint"
    private var idHelper: IdHelper?
    private var matchingSuccessDestination: String?
    private var receivingMessageDestination: String?
    private var chattingViewModel: ChattingViewModel?
    
    var stompClient = StompClientLib()
    
    var isMatchSuccess: Bool = false
    
    //MARK: - Setting
    func connectToWebSocket(idHelper: IdHelper) throws {
        self.idHelper = idHelper
        
        guard let url = URL(string: socketURL) else {
            print("DEBUG: WebSocketHelper.connectToWebSocket: invalid url")
            throw WebSocketHelperError.invalidURLError
        }
        
        guard let userId = idHelper.getUserId() else {
            print("DEBUG: WebSocketHelper.connectToWebSocket: nil userId")
            throw WebSocketHelperError.nilError
        }
        
        stompClient.openSocketWithURLRequest(
            request: NSURLRequest(url: url),
            delegate: self,
            connectionHeaders: ["userId": userId]
        )
        
    }
    
    func disconnectFromWebSocket() {
        stompClient.disconnect()
    }
    
    //MARK: - Subscribe
    func subscribeToMatchingSuccess() throws {
        guard let idHelper else {
            print("DEBUG: WebSocketHelper.subscribeToMatchingSuccess: nil idHelper")
            throw WebSocketHelperError.nilError
        }
        
        guard let userId = idHelper.getUserId() else {
            print("DEBUG: WebSocketHelper.subscribeToMatchingSuccess: nil userId")
            throw WebSocketHelperError.nilError
        }
        
        let matchingSuccessDestination = "/user/\(userId)/queue/v1/matching/success"
        
        if stompClient.isConnected() {
            stompClient.subscribe(
                destination: matchingSuccessDestination
            )
            self.matchingSuccessDestination = matchingSuccessDestination
        } else {
            print("DEBUG: WebSocketHelper.subscribeToMatchingSuccess: Not connected to websocket")
            throw WebSocketHelperError.connectError
        }
    }
    
    func subscribeToRecieveMessage() throws {
        guard let idHelper else {
            print("DEBUG: WebSocketHelper.subscribeToRecieveMessage: nil idHelper")
            throw WebSocketHelperError.nilError
        }
        
        guard let roomId = idHelper.getRoomId() else {
            print("DEBUG: WebSocketHelper.subscribeToRecieveMessage: nil roomId")
            throw WebSocketHelperError.nilError
        }
        
        let receiveMessageDestination = "/topic/v1/rooms/\(roomId)/messages/new"
        
        if stompClient.isConnected() {
            stompClient.subscribe(
                destination: receiveMessageDestination
            )
            self.receivingMessageDestination = receiveMessageDestination
        } else {
            print("DEBUG: WebSocketHelper.subscribeToRecieveMessage: not connected")
            throw WebSocketHelperError.connectError
        }
    }
    
    func unsubscribeFromMatchingSuccess() throws {
        guard let idHelper else {
            print("DEBUG: WebSocketHelper.unsubscribeFromMatchingSuccess: nil idHelper")
            throw WebSocketHelperError.nilError
        }
        
        guard let userId = idHelper.getUserId() else {
            print("DEBUG: WebSocketHelper.unsubscribeFromMatchingSuccess: nil userId")
            throw WebSocketHelperError.nilError
        }
        
        let matchingSuccessDestination = "/user/\(userId)/queue/v1/matching/success"
        
        stompClient.unsubscribe(destination: matchingSuccessDestination)
    }
    
    func unsubscribeFromRecieveMessage() throws {
        guard let idHelper else {
            print("DEBUG: WebSocketHelper.unsubscribeFromRecieveMessage: nil idHelper")
            throw WebSocketHelperError.nilError
        }
        
        guard let roomId = idHelper.getRoomId() else {
            print("DEBUG: WebSocketHelper.unsubscribeFromRecieveMessage: nil roomId")
            throw WebSocketHelperError.nilError
        }
        
        let receiveMessageDestination = "/topic/v1/rooms/\(roomId)/messages/new"
        
        stompClient.unsubscribe(destination: receiveMessageDestination)
    }
    
    //MARK: - Send
    func requestMatching() throws {
        guard let idHelper else {
            print("DEBUG: WebSocketHelper.requestMatching: nil idHelper")
            throw WebSocketHelperError.nilError
        }
        
        guard let userId = idHelper.getUserId() else {
            print("DEBUG: WebSocketHelper.requestMatching: nil userId")
            throw WebSocketHelperError.nilError
        }
        
        let requestMatchingDestination = "/v1/matching/apply"
        let payloadObject: [String: Any] = ["userId": userId]
        
        if stompClient.isConnected() {
            stompClient.sendJSONForDict(
                dict: payloadObject as AnyObject,
                toDestination: requestMatchingDestination
            )
            isMatchSuccess = false
        } else {
            print("DEBUG: WebSocketHelper.requestMatching: Not connected to Stomp")
            throw WebSocketHelperError.connectError
        }
    }
    
    func cancelMatching() throws {
        guard let idHelper else {
            print("DEBUG: WebSocketHelper.cancelMatching: nil idHelper")
            throw WebSocketHelperError.nilError
        }
        
        guard let userId = idHelper.getUserId() else {
            print("DEBUG: WebSocketHelper.cancelMatching: nil userId")
            throw WebSocketHelperError.nilError
        }
        
        let cancelMatchingDestination = "/v1/matching/cancel"
        let payloadObject: [String: Any] = ["userId": userId]
        
        if stompClient.isConnected() {
            stompClient.sendJSONForDict(
                dict: payloadObject as AnyObject,
                toDestination: cancelMatchingDestination
            )
            isMatchSuccess = false
        } else {
            print("DEBUG: WebSocketHelper.cancelMatching: not connected")
            throw WebSocketHelperError.connectError
        }
    }
    
    func sendMessage(_ message: String) throws {
        guard let idHelper else {
            print("DEBUG: WebSocketHelper.sendMessage: nil idHelper")
            throw WebSocketHelperError.nilError
        }
        
        guard let roomId = idHelper.getRoomId() else {
            print("DEBUG: WebSocketHelper.sendMessage: nil roomId")
            throw WebSocketHelperError.nilError
        }
        
        let sendMessageDestination = "/v1/rooms/\(roomId)/messages/send"
        
        if stompClient.isConnected() {
            stompClient.sendMessage(
                message: message,
                toDestination: sendMessageDestination,
                withHeaders: nil,
                withReceipt: nil
            )
        } else {
            print("DEBUG: WebSocketHelper.sendMessage: not connected")
            throw WebSocketHelperError.connectError
        }
    }
    
    func enterRoom() throws {
        guard let idHelper else {
            print("DEBUG: WebSocketHelper.enterRoom: nil idHelper")
            throw WebSocketHelperError.nilError
        }
        
        guard let roomId = idHelper.getRoomId(), let userId = idHelper.getUserId() else {
            print("DEBUG: WebSocketHelper.enterRoom: nil roomId or userId")
            throw WebSocketHelperError.nilError
        }
        
        let enterRoomDestination = "/v1/rooms/\(roomId)/enter"
        let payloadObject: [String: Any] = ["userId": userId]
        
        if stompClient.isConnected() {
            stompClient.sendJSONForDict(
                dict: payloadObject as AnyObject,
                toDestination: enterRoomDestination
            )
        } else {
            print("DEBUG: WebSocketHelper.enterRoom: not connected")
            throw WebSocketHelperError.connectError
        }
    }
    
    func exitRoom(roomId: String) throws {
        guard let idHelper else {
            print("DEBUG: WebSocketHelper.exitRoom: nil idHelper")
            throw WebSocketHelperError.nilError
        }
        
        guard let roomId = idHelper.getRoomId(), let userId = idHelper.getUserId() else {
            print("DEBUG: WebSocketHelper.exitRoom: nil roomId or userId")
            throw WebSocketHelperError.nilError
        }
        
        let exitRoomDestination = "/v1/rooms/\(roomId)/exit"
        let payloadObject: [String: Any] = ["userId": userId]
        
        if stompClient.isConnected() {
            stompClient.sendJSONForDict(
                dict: payloadObject as AnyObject,
                toDestination: exitRoomDestination
            )
        } else {
            print("DEBUG: WebSocketHelper.exitRoom: Not connected to Stomp")
            throw WebSocketHelperError.connectError
        }
    }
    
    //MARK: - ETC
    func setChattingViewModel(_ chattingViewModel: ChattingViewModel) {
        self.chattingViewModel = chattingViewModel
    }
}

extension WebSocketHelper: StompClientLibDelegate {
    func stompClient(
        client: StompClientLib!,
        didReceiveMessageWithJSONBody jsonBody: AnyObject?,
        akaStringBody stringBody: String?,
        withHeader header: [String : String]?,
        withDestination destination: String
    ) {
        guard let body = jsonBody as? [String: AnyObject],
              let status = body["status"] as? String else {
            print("DEBUG: WebSocketHelper stompClient Invalid response structure")
            return
        }
        
        if status == "SUCCESS",
           let data = body["data"] as? [String: AnyObject] {
            
            // data : { "roomId" : 0 }
            if destination == matchingSuccessDestination {
                //매칭 성공 시 roomId 새로 할당
                self.idHelper?.setRoomId(data["roomId"] as? String ?? "")
                self.isMatchSuccess = true
                print("DEBUG: WebSocketHelper stompClient subscribeToMatchingSuccess success")
            // data : MessageData.swift
            } else if destination == receivingMessageDestination {
                guard let messageData = MessageData(jsonString: data) else {
                    print("DEBUG: WebSocketHelper stompClient Invalid message data")
                    return
                }
                chattingViewModel?.addMessage(messageData: messageData)
            }
        } else {
            print("DEBUG: WebSocketHelper stompClient subscribeToMatchingSuccess failed: \(status)")
        }
    }
    
    func stompClientDidDisconnect(client: StompClientLib!) {
        print("stompClientDidDisconnect")
    }
    
    func stompClientDidConnect(client: StompClientLib!) {
        print("stompClientDidConnect")
        do {
            try subscribeToMatchingSuccess()
        } catch {
            print("DEBUG: subscribeToMatchingSuccess failed: \(error.localizedDescription)")
        }
    }
    
    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
        print("serverDidSendReceipt withReceiptId: \(receiptId)")
    }
    
    func serverDidSendError(client: StompClientLib!, withErrorMessage description: String, detailedErrorMessage message: String?) {
        print("serverDidSendError withErrorMessage: \(description), detailedErrorMessage: \(message ?? "")")
    }
    
    func serverDidSendPing() {
        print("serverDidSendPing")
    }
}
