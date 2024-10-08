//
//  MessageListResponse.swift
//  ranchat
//
//  Created by 김견 on 9/29/24.
//

import Foundation

struct MessagesListResponseData: Codable {
    var items: [MessageData]
    var page: Int
    var size: Int
    var totalCount: Int
    var totalPage: Int
    var empty: Bool
}

struct MessageListResponse: Codable {
    var status: String
    var message: String
    var serverDateTime: String
    var data: MessagesListResponseData
}
