//
//  RoomPageDTO.swift
//  ranchat
//

import Foundation

struct RoomPageDTO: Codable {
    let items: [RoomDTO]
    let page: Int
    let size: Int
    let totalCount: Int
    let totalPage: Int
    let empty: Bool

    func toDomain() -> RoomPage {
        RoomPage(items: items.map { $0.toDomain() }, totalCount: totalCount)
    }
}
