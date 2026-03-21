//
//  Message.swift
//  ranchat
//

import Foundation

struct Message: Identifiable, Equatable, Hashable {
    let id: Int
    let roomId: Int
    let userId: String
    let participantId: Int
    let participantName: String
    let content: String
    let messageType: MessageType
    let contentType: ContentType
    let senderType: SenderType
    let createdAt: Date
}
