//
//  RoomDataList.swift
//  ranchat
//
//  Created by 김견 on 9/28/24.
//

import Foundation

struct Data: Codable {
    var items: [RoomData]
    var page: Int
    var size: Int
    var totalCount: Int
    var totalPage: Int
    var empty: Bool
}

struct RoomDataList: Codable {
    var status: String
    var message: String
    var serverDateTime: String
    var data: Data
}
