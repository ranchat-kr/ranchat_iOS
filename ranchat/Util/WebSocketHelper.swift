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
    
    var stompClient = StompClientLib()
    
    func connectToWebSocket(idHelper: IdHelper) throws {
        self.idHelper = idHelper
        
        guard let url = URL(string: socketURL) else {
            throw WebSocketHelperError.invalidURLError
        }
        
        guard let userId = idHelper.getUserId() else {
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
            throw WebSocketHelperError.nilError
        }
        
        guard let userId = idHelper.getUserId() else {
            throw WebSocketHelperError.nilError
        }
        
        let matchingSuccessDestination = "/user/\(userId)/queue/v1/matching/success"
        
        if stompClient.isConnected() {
            stompClient.subscribeWithHeader(
                destination: matchingSuccessDestination,
                withHeader: ["matchingSuccess": "true"]
            )
        } else {
            throw WebSocketHelperError.connectError
        }
    }
    
    func subscribeToRecieveMessage() throws {
        guard let idHelper else {
            throw WebSocketHelperError.nilError
        }
        
        guard let roomId = idHelper.getRoomId() else {
            throw WebSocketHelperError.nilError
        }
        
        let receiveMessageDestination = "/topic/v1/rooms/\(roomId)/messages/new"
        
        if stompClient.isConnected() {
            
            stompClient.subscribeWithHeader(
                destination: receiveMessageDestination,
                withHeader: ["recieveMessage": "true"]
            )
        } else {
            throw WebSocketHelperError.connectError
        }
    }
    
    func unsubscribeFromMatchingSuccess() throws {
        guard let idHelper else {
            throw WebSocketHelperError.nilError
        }
        
        guard let userId = idHelper.getUserId() else {
            throw WebSocketHelperError.nilError
        }
        
        let matchingSuccessDestination = "/user/\(userId)/queue/v1/matching/success"
        
        stompClient.unsubscribe(destination: matchingSuccessDestination)
    }
    
    func unsubscribeFromRecieveMessage() throws {
        guard let idHelper else {
            throw WebSocketHelperError.nilError
        }
        
        guard let roomId = idHelper.getRoomId() else {
            throw WebSocketHelperError.nilError
        }
        
        let receiveMessageDestination = "/topic/v1/rooms/\(roomId)/messages/new"
        
        stompClient.unsubscribe(destination: receiveMessageDestination)
    }
    
    //MARK: - Recieve
    
    
    //MARK: - Send
    
    func requestMatching() throws {
        guard let idHelper else {
            throw WebSocketHelperError.nilError
        }
        
        guard let userId = idHelper.getUserId() else {
            throw WebSocketHelperError.nilError
        }
        
        let requestMatchingDestination = "/v1/matching/apply"
        let payloadObject: [String: Any] = ["userId": userId]
        
        if stompClient.isConnected() {
            stompClient.sendJSONForDict(
                dict: payloadObject as AnyObject,
                toDestination: requestMatchingDestination
            )
        } else {
            throw WebSocketHelperError.connectError
        }
    }
    
    func sendMessage(_ message: String) throws {
        guard let idHelper else {
            throw WebSocketHelperError.nilError
        }
        
        guard let roomId = idHelper.getRoomId() else {
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
            throw WebSocketHelperError.connectError
        }
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
//        guard let json = jsonBody as? [String: AnyObject] else { return }
//        print("json: \(json)")
        
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
