//
//  RoomDTO.swift
//  ranchat
//

import Foundation

struct RoomDTO: Codable {
    let id: Int
    let title: String
    let type: String
    let latestMessage: String
    let latestMessageAt: String

    private static let isoFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    func toDomain() -> Room {
        Room(
            id: id,
            title: title,
            type: RoomType(rawValue: type) ?? .unknown,
            latestMessage: latestMessage,
            latestMessageAt: Self.isoFormatter.date(from: latestMessageAt) ?? Date()
        )
    }
}
