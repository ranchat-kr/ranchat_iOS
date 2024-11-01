//
//  RoomData.swift
//  ranchat
//
//  Created by 김견 on 9/28/24.
//

import Foundation

struct RoomData: Codable, Equatable {
    var id: Int
    var title: String
    var type: String
    var latestMessage: String
    var latestMessageAt: String
}
