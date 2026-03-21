//
//  MessagePageDTO.swift
//  ranchat
//

import Foundation

struct MessagePageDTO: Codable {
    let items: [MessageDTO]
    let page: Int
    let size: Int
    let totalCount: Int
    let totalPage: Int
    let empty: Bool

    func toDomain() -> MessagePage {
        MessagePage(items: items.map { $0.toDomain() }, totalCount: totalCount)
    }
}
