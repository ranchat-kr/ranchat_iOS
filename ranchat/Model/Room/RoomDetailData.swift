//
//  RoomDetailData.swift
//  ranchat
//
//  Created by 김견 on 9/28/24.
//

import Foundation

struct RoomDetailData: Codable {
    var id: Int
    var title: String
    var type: String
    var participants: [ParticipantsData]
}
