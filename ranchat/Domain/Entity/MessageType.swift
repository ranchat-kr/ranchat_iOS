//
//  MessageType.swift
//  ranchat
//

import Foundation

enum MessageType: String {
    case enter = "ENTER"
    case leave = "LEAVE"
    case chat = "CHAT"
    case unknown
}

enum SenderType: String {
    case user = "USER"
    case bot = "BOT"
    case unknown
}

enum ContentType: String {
    case text = "TEXT"
    case unknown
}
