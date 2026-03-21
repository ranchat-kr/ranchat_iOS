//
//  Room.swift
//  ranchat
//

import Foundation

struct Room: Identifiable, Equatable {
    let id: Int
    let title: String
    let type: RoomType
    let latestMessage: String
    let latestMessageAt: Date
}
