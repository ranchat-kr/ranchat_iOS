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
    private let className = "WebSocketHelper"
    private let socketURL = "wss://\(DefaultData.shared.domain)/endpoint"
    private var idHelper: IdHelper?
    private var matchingSuccessDestination: String?
    private var receivingMessageDestination: String?
    private var chattingViewModel: ChattingViewModel?
    
    var stompClient = StompClientLib()
    
    var isMatchSuccess: Bool = false
    
    var onSuccessMatching: (() -> Void)?
    
    //MARK: - Init Setting
    func connectToWebSocket() throws {
        let userId = try getUserId()
        
        guard let url = URL(string: socketURL) else {
            Logger.shared.log(self.className, #function, "Failed to create URL", .error)
            
            throw WebSocketHelperError.invalidURLError
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
    
    func setIdHelper(idHelper: IdHelper) {
        self.idHelper = idHelper
    }
    
    //MARK: - Subscribe
    func subscribeToMatchingSuccess() throws {
        let userId = try getUserId()
        
        let matchingSuccessDestination = "/user/\(userId)/queue/v1/matching/success"
        
        if stompClient.isConnected() {
            stompClient.subscribe(
                destination: matchingSuccessDestination
            )
            self.matchingSuccessDestination = matchingSuccessDestination
            
            Logger.shared.log(self.className, #function, "Success subscribing to matching success")
        } else {
            logForStompNotConnected(#function)
            
            throw WebSocketHelperError.connectError
        }
    }
    
    func subscribeToRecieveMessage() throws {
        let roomId = try getRoomId()
        
        let receiveMessageDestination = "/topic/v1/rooms/\(roomId)/messages/new"
        
        if stompClient.isConnected() {
            stompClient.subscribe(
                destination: receiveMessageDestination
            )
            self.receivingMessageDestination = receiveMessageDestination
            
            Logger.shared.log(self.className, #function, "Success subscribing to receive message")
        } else {
            logForStompNotConnected(#function)
            
            throw WebSocketHelperError.connectError
        }
    }
    
    func unsubscribeFromMatchingSuccess() throws {
        let userId = try getUserId()
        
        let matchingSuccessDestination = "/user/\(userId)/queue/v1/matching/success"
        
        stompClient.unsubscribe(destination: matchingSuccessDestination)
    }
    
    func unsubscribeFromRecieveMessage(roomId: String) throws {
        let receiveMessageDestination = "/topic/v1/rooms/\(roomId)/messages/new"
        
        stompClient.unsubscribe(destination: receiveMessageDestination)
        
        do {
            try connectToWebSocket()
        } catch {
            Logger.shared.log(self.className, #function, "Failed to reconnect to websocket")
        }
    }
    
    //MARK: - Send
    func requestMatching() throws {
        let userId = try getUserId()
        let requestMatchingDestination = "/v1/matching/apply"
        let payloadObject: [String: Any] = ["userId": userId]
        
        if stompClient.isConnected() {
            stompClient.sendJSONForDict(
                dict: payloadObject as AnyObject,
                toDestination: requestMatchingDestination
            )
            isMatchSuccess = false
            
            Logger.shared.log(self.className, #function, "Success sending request matching")
        } else {
            logForStompNotConnected(#function)
            
            throw WebSocketHelperError.connectError
        }
    }
    
    func cancelMatching() throws {
        let userId = try getUserId()
        let cancelMatchingDestination = "/v1/matching/cancel"
        let payloadObject: [String: Any] = ["userId": userId]
        
        if stompClient.isConnected() {
            stompClient.sendJSONForDict(
                dict: payloadObject as AnyObject,
                toDestination: cancelMatchingDestination
            )
            isMatchSuccess = false
            
            Logger.shared.log(self.className, #function, "Success sending cancel matching")
        } else {
            logForStompNotConnected(#function)
            
            throw WebSocketHelperError.connectError
        }
    }
    
    func sendMessage(_ content: String) throws {
        let userId = try getUserId()
        let roomId = try getRoomId()
        let sendMessageDestination = "/v1/rooms/\(roomId)/messages/send"
        let payloadObject: [String: Any] = [
            "userId": userId,
            "content": content,
            "contentType": "TEXT",
        ]
        
        if stompClient.isConnected() {
            
            stompClient.sendJSONForDict(
                dict: payloadObject as AnyObject,
                toDestination: sendMessageDestination
            )
            
            Logger.shared.log(self.className, #function, "Success sending message")
        } else {
            logForStompNotConnected(#function)
            
            throw WebSocketHelperError.connectError
        }
    }
    
    func enterRoom() throws {
        let userId = try getUserId()
        let roomId = try getRoomId()
        let enterRoomDestination = "/v1/rooms/\(roomId)/enter"
        let payloadObject: [String: Any] = ["userId": userId]
        
        if stompClient.isConnected() {
            stompClient.sendJSONForDict(
                dict: payloadObject as AnyObject,
                toDestination: enterRoomDestination
            )
            Logger.shared.log(self.className, #function, "Success entering room")
            
            do {
                try subscribeToRecieveMessage()
            } catch {
                Logger.shared.log(self.className, #function, "Failed to subscribe to recieve message error: \(error.localizedDescription)", .error)
                
                throw WebSocketHelperError.connectError
            }
        } else {
            logForStompNotConnected(#function)
            
            throw WebSocketHelperError.connectError
        }
    }
    
    func exitRoom(roomId: String) throws {
        let userId = try getUserId()
        let exitRoomDestination = "/v1/rooms/\(roomId)/exit"
        let payloadObject: [String: Any] = ["userId": userId]
        
        if stompClient.isConnected() {
            do {
                try unsubscribeFromRecieveMessage(roomId: roomId)
            } catch {
                Logger.shared.log(self.className, #function, "Failed to unsubscribe from recieveMessage: \(error.localizedDescription)", .error)
                
                throw WebSocketHelperError.connectError
            }
            
            stompClient.sendJSONForDict(
                dict: payloadObject as AnyObject,
                toDestination: exitRoomDestination
            )
            
            Logger.shared.log(self.className, #function, "Success to exit room with roomId: \(roomId)")
        } else {
            logForStompNotConnected(#function)
            
            throw WebSocketHelperError.connectError
        }
    }
    
    //MARK: - ETC
    func setChattingViewModel(_ chattingViewModel: ChattingViewModel) {
        self.chattingViewModel = chattingViewModel
    }
    
    func getUserId() throws -> String {
        guard let userId = idHelper?.getUserId() else {
            Logger.shared.log(self.className, #function, "Failed to get user id", .error)
            
            throw ApiHelperError.nilError
        }
        
        return userId
    }
    
    func getRoomId() throws -> String {
        guard let roomId = idHelper?.getRoomId() else {
            Logger.shared.log(self.className, #function, "Failed to get room id", .error)
            
            throw ApiHelperError.nilError
        }
        
        return roomId
    }
    
    func logForStompNotConnected(_ functionName: String) {
        Logger.shared.log(self.className, functionName, "stompClient not connected", .error)
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
            Logger.shared.log(self.className, #function, "Failed to parse response body as JSON object or status", .error)
            
            return
        }
        
        if status == "SUCCESS",
           let data = body["data"] as? [String: AnyObject] {
            // data : { "roomId" : 0 }
            if destination == matchingSuccessDestination {
                Logger.shared.log(self.className, #function, "Success to receive matching success message")
                
                //매칭 성공 시 roomId 새로 할당
                let roomId = String(data["roomId"] as? Int ?? 0)
                self.idHelper?.setRoomId(roomId)
                self.isMatchSuccess = true
            // data : MessageData.swift
            } else if destination == receivingMessageDestination {
                guard let messageData = MessageData(jsonString: data) else {
                    Logger.shared.log(self.className, #function, "Failed to parse message data as JSON object", .error)
                    
                    return
                }
                chattingViewModel?.addMessage(messageData: messageData)

            } else {
                Logger.shared.log(self.className, #function, "Failed to Receive message with invalid destination: \(destination)", .error)
            }
        } else {
            Logger.shared.log(self.className, #function, "Failed to Receive message with invalid status: \(status)")
        }
    }
    
    func stompClientDidDisconnect(client: StompClientLib!) {
        Logger.shared.log(self.className, #function, "Stomp client did disconnected")
        do {
            //try unsubscribeFromMatchingSuccess()
            try connectToWebSocket()
        } catch {
            Logger.shared.log(self.className, #function, "Failed to reconnect to WebSocket server: \(error.localizedDescription)", .error)
        }
    }
    
    func stompClientDidConnect(client: StompClientLib!) {
        Logger.shared.log(self.className, #function, "Stomp client did connected")
        do {
            try subscribeToMatchingSuccess()
        } catch {
            Logger.shared.log(self.className, #function, "Failed to subscribe to matching success: \(error.localizedDescription)", .error)
        }
    }
    
    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
        Logger.shared.log(self.className, #function, "Server did send receipt with receiptId: \(receiptId)")
    }
    
    func serverDidSendError(client: StompClientLib!, withErrorMessage description: String, detailedErrorMessage message: String?) {
        Logger.shared.log(self.className, #function, "Server did send error withErrorMessage: \(description), detailedErrorMessage: \(message ?? "")", .error)
    }
    
    func serverDidSendPing() {
        Logger.shared.log(self.className, #function, "Server did send ping")
    }
}
