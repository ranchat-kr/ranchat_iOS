//
//  WebSocketService.swift
//  ranchat
//

import Foundation

enum WebSocketServiceError: Error {
    case notConnected
    case nilParameter
}

protocol WebSocketService: AnyObject {
    func connect(userId: String) throws
    func disconnect()
    func requestMatching(userId: String) throws
    func cancelMatching(userId: String) throws
    func enterRoom(userId: String, roomId: String) throws
    func exitRoom(userId: String, roomId: String) throws
    func sendMessage(userId: String, roomId: String, content: String) throws
    func subscribeMessages(roomId: String) throws
    func unsubscribeMessages(roomId: String) throws
    func activateParticipant(userId: String, roomId: String) throws
    func setOnMatchingSuccess(_ handler: @escaping @MainActor (String) -> Void)
    func setOnMessageReceived(_ handler: @escaping @MainActor (Message) -> Void)
}
