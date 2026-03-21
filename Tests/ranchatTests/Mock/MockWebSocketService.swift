//
//  MockWebSocketService.swift
//  ranchatTests
//

@testable import ranchat

class MockWebSocketService: WebSocketService {
    var shouldThrow = false
    var connectCallCount = 0
    var sendMessageCallCount = 0
    var exitRoomCallCount = 0
    var unsubscribeCallCount = 0

    var onMatchingSuccessHandler: (@MainActor (String) -> Void)?
    var onMessageReceivedHandler: (@MainActor (Message) -> Void)?

    func connect(userId: String) throws {
        connectCallCount += 1
        if shouldThrow { throw WebSocketServiceError.notConnected }
    }
    func disconnect() {}
    func requestMatching(userId: String) throws { if shouldThrow { throw WebSocketServiceError.notConnected } }
    func cancelMatching(userId: String) throws { if shouldThrow { throw WebSocketServiceError.notConnected } }
    func enterRoom(userId: String, roomId: String) throws { if shouldThrow { throw WebSocketServiceError.notConnected } }
    func exitRoom(userId: String, roomId: String) throws {
        exitRoomCallCount += 1
        if shouldThrow { throw WebSocketServiceError.notConnected }
    }
    func sendMessage(userId: String, roomId: String, content: String) throws {
        sendMessageCallCount += 1
        if shouldThrow { throw WebSocketServiceError.notConnected }
    }
    func subscribeMessages(roomId: String) throws { if shouldThrow { throw WebSocketServiceError.notConnected } }
    func unsubscribeMessages(roomId: String) throws {
        unsubscribeCallCount += 1
        if shouldThrow { throw WebSocketServiceError.notConnected }
    }
    func activateParticipant(userId: String, roomId: String) throws { if shouldThrow { throw WebSocketServiceError.notConnected } }
    func setOnMatchingSuccess(_ handler: @escaping @MainActor (String) -> Void) { onMatchingSuccessHandler = handler }
    func setOnMessageReceived(_ handler: @escaping @MainActor (Message) -> Void) { onMessageReceivedHandler = handler }
}
