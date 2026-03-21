//
//  WebSocketHelper.swift
//  ranchat
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
final class WebSocketHelper: WebSocketService {
    private let className = "WebSocketHelper"
    private let socketURL = "wss://\(DefaultData.shared.domain)/endpoint"

    private var storedUserId: String?
    private var matchingSuccessDestination: String?
    private var receivingMessageDestination: String?

    private var onMatchingSuccessHandler: (@MainActor (String) -> Void)?
    private var onMessageReceivedHandler: (@MainActor (Message) -> Void)?

    var stompClient = StompClientLib()

    // MARK: - WebSocketService

    func connect(userId: String) throws {
        storedUserId = userId
        guard let url = URL(string: socketURL) else {
            Logger.shared.log(className, #function, "Failed to create URL", .error)
            throw WebSocketHelperError.invalidURLError
        }
        stompClient.openSocketWithURLRequest(
            request: NSURLRequest(url: url),
            delegate: self,
            connectionHeaders: ["userId": userId]
        )
    }

    func disconnect() {
        stompClient.disconnect()
    }

    func requestMatching(userId: String) throws {
        let requestMatchingDestination = "/v1/matching/apply"
        let payloadObject: [String: Any] = ["userId": userId]

        if stompClient.isConnected() {
            stompClient.sendJSONForDict(dict: payloadObject as AnyObject, toDestination: requestMatchingDestination)
            Logger.shared.log(className, #function, "Success sending request matching")
        } else {
            logForStompNotConnected(#function)
            throw WebSocketHelperError.connectError
        }
    }

    func cancelMatching(userId: String) throws {
        let cancelMatchingDestination = "/v1/matching/cancel"
        let payloadObject: [String: Any] = ["userId": userId]

        if stompClient.isConnected() {
            stompClient.sendJSONForDict(dict: payloadObject as AnyObject, toDestination: cancelMatchingDestination)
            Logger.shared.log(className, #function, "Success sending cancel matching")
        } else {
            logForStompNotConnected(#function)
            throw WebSocketHelperError.connectError
        }
    }

    func enterRoom(userId: String, roomId: String) throws {
        let enterRoomDestination = "/v1/rooms/\(roomId)/enter"
        let payloadObject: [String: Any] = ["userId": userId]

        if stompClient.isConnected() {
            stompClient.sendJSONForDict(dict: payloadObject as AnyObject, toDestination: enterRoomDestination)
            Logger.shared.log(className, #function, "Success entering room")
            try subscribeMessages(roomId: roomId)
        } else {
            logForStompNotConnected(#function)
            throw WebSocketHelperError.connectError
        }
    }

    func exitRoom(userId: String, roomId: String) throws {
        let exitRoomDestination = "/v1/rooms/\(roomId)/exit"
        let payloadObject: [String: Any] = ["userId": userId]

        if stompClient.isConnected() {
            try unsubscribeMessages(roomId: roomId)
            stompClient.sendJSONForDict(dict: payloadObject as AnyObject, toDestination: exitRoomDestination)
            Logger.shared.log(className, #function, "Success to exit room with roomId: \(roomId)")
        } else {
            logForStompNotConnected(#function)
            throw WebSocketHelperError.connectError
        }
    }

    func sendMessage(userId: String, roomId: String, content: String) throws {
        let sendMessageDestination = "/v1/rooms/\(roomId)/messages/send"
        let payloadObject: [String: Any] = [
            "userId": userId,
            "content": content,
            "contentType": "TEXT",
        ]

        if stompClient.isConnected() {
            stompClient.sendJSONForDict(dict: payloadObject as AnyObject, toDestination: sendMessageDestination)
            Logger.shared.log(className, #function, "Success sending message")
        } else {
            logForStompNotConnected(#function)
            throw WebSocketHelperError.connectError
        }
    }

    func subscribeMessages(roomId: String) throws {
        let receiveMessageDestination = "/topic/v1/rooms/\(roomId)/messages/new"

        if stompClient.isConnected() {
            stompClient.subscribe(destination: receiveMessageDestination)
            self.receivingMessageDestination = receiveMessageDestination
            Logger.shared.log(className, #function, "Success subscribing to receive message")
        } else {
            logForStompNotConnected(#function)
            throw WebSocketHelperError.connectError
        }
    }

    func unsubscribeMessages(roomId: String) throws {
        let receiveMessageDestination = "/topic/v1/rooms/\(roomId)/messages/new"
        stompClient.unsubscribe(destination: receiveMessageDestination)

        guard let userId = storedUserId else {
            Logger.shared.log(className, #function, "storedUserId is nil", .error)
            throw WebSocketHelperError.nilError
        }
        try connect(userId: userId)
    }

    func activateParticipant(userId: String, roomId: String) throws {
        let activateParticipantDestination = "/v1/rooms/\(roomId)/activate-participant"
        let payloadObject: [String: Any] = ["userId": userId]

        if stompClient.isConnected() {
            stompClient.sendJSONForDict(dict: payloadObject as AnyObject, toDestination: activateParticipantDestination)
            Logger.shared.log(className, #function, "Success to activate participant roomId: \(roomId)")
        } else {
            logForStompNotConnected(#function)
            throw WebSocketHelperError.connectError
        }
    }

    func setOnMatchingSuccess(_ handler: @escaping @MainActor (String) -> Void) {
        onMatchingSuccessHandler = handler
    }

    func setOnMessageReceived(_ handler: @escaping @MainActor (Message) -> Void) {
        onMessageReceivedHandler = handler
    }

    // MARK: - Private

    private func subscribeToMatchingSuccess() throws {
        guard let userId = storedUserId else {
            Logger.shared.log(className, #function, "storedUserId is nil", .error)
            throw WebSocketHelperError.nilError
        }

        let matchingSuccessDestination = "/user/\(userId)/queue/v1/matching/success"

        if stompClient.isConnected() {
            stompClient.subscribe(destination: matchingSuccessDestination)
            self.matchingSuccessDestination = matchingSuccessDestination
            Logger.shared.log(className, #function, "Success subscribing to matching success")
        } else {
            logForStompNotConnected(#function)
            throw WebSocketHelperError.connectError
        }
    }

    private func logForStompNotConnected(_ functionName: String) {
        Logger.shared.log(className, functionName, "stompClient not connected", .error)
    }
}

extension WebSocketHelper: StompClientLibDelegate {
    func stompClient(
        client: StompClientLib!,
        didReceiveMessageWithJSONBody jsonBody: AnyObject?,
        akaStringBody stringBody: String?,
        withHeader header: [String: String]?,
        withDestination destination: String
    ) {
        guard let body = jsonBody as? [String: AnyObject],
              let status = body["status"] as? String else {
            Logger.shared.log(className, #function, "Failed to parse response body", .error)
            return
        }

        if status == "SUCCESS",
           let data = body["data"] as? [String: AnyObject] {
            if destination == matchingSuccessDestination {
                Logger.shared.log(className, #function, "Success to receive matching success message")
                let roomId = String(data["roomId"] as? Int ?? 0)
                let handler = onMatchingSuccessHandler
                Task { @MainActor in
                    handler?(roomId)
                }
            } else if destination == receivingMessageDestination {
                guard let dto = MessageDTO(jsonString: data) else {
                    Logger.shared.log(className, #function, "Failed to parse message data", .error)
                    return
                }
                let message = dto.toDomain()
                let handler = onMessageReceivedHandler
                Task { @MainActor in
                    handler?(message)
                }
            } else {
                Logger.shared.log(className, #function, "Invalid destination: \(destination)", .error)
            }
        } else {
            Logger.shared.log(className, #function, "Invalid status: \(status)")
        }
    }

    func stompClientDidDisconnect(client: StompClientLib!) {
        Logger.shared.log(className, #function, "Stomp client did disconnected")
        guard let userId = storedUserId else { return }
        do {
            try connect(userId: userId)
        } catch {
            Logger.shared.log(className, #function, "Failed to reconnect: \(error.localizedDescription)", .error)
        }
    }

    func stompClientDidConnect(client: StompClientLib!) {
        Logger.shared.log(className, #function, "Stomp client did connected")
        do {
            try subscribeToMatchingSuccess()
        } catch {
            Logger.shared.log(className, #function, "Failed to subscribe to matching success: \(error.localizedDescription)", .error)
        }
    }

    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
        Logger.shared.log(className, #function, "Server did send receipt with receiptId: \(receiptId)")
    }

    func serverDidSendError(client: StompClientLib!, withErrorMessage description: String, detailedErrorMessage message: String?) {
        Logger.shared.log(className, #function, "Server did send error: \(description), \(message ?? "")", .error)
    }

    func serverDidSendPing() {
        Logger.shared.log(className, #function, "Server did send ping")
    }
}
