//
//  MessageData.swift
//  ranchat
//
//  Created by 김견 on 9/29/24.
//

import Foundation

struct MessageData: Codable, Identifiable, Equatable {
    var id: Int
    var roomId: Int?
    var userId: String?
    var participantId: Int?
    var participantName: String?
    var content: String
    var messageType: String?
    var contentType: String?
    var senderType: String?
    var createdAt: String?
}
