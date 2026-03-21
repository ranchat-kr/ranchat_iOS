//
//  RoomDTO.swift
//  ranchat
//

import Foundation

struct RoomDTO: Codable {
    let id: Int
    let title: String
    let type: String
    let latestMessage: String
    let latestMessageAt: String

    func toDomain() -> Room {
        Room(id: id, title: title, type: type, latestMessage: latestMessage, latestMessageAt: latestMessageAt)
    }
}
