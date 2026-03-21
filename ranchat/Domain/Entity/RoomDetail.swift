//
//  RoomDetail.swift
//  ranchat
//

import Foundation

struct Participant {
    let id: Int
    let userId: String
    let name: String
}

struct RoomDetail {
    let id: Int
    let title: String
    let type: RoomType
    let participants: [Participant]
}
