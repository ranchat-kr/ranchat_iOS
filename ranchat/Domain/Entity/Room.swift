//
//  Room.swift
//  ranchat
//

import Foundation

struct Room: Identifiable, Equatable {
    let id: Int
    let title: String
    let type: String
    let latestMessage: String
    let latestMessageAt: String
}
