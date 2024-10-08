//
//  RoomDetailDataResponse.swift
//  ranchat
//
//  Created by 김견 on 9/28/24.
//

import Foundation

struct RoomDetailDataResponse: Codable {
    var status: String
    var message: String
    var serverDateTime: String
    var data: RoomDetailData
}
