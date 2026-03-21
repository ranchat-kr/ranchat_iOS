//
//  RoomDetailDTO.swift
//  ranchat
//

import Foundation

struct ParticipantDTO: Codable {
    let id: Int
    let userId: String
    let name: String

    func toDomain() -> Participant {
        Participant(id: id, userId: userId, name: name)
    }
}

struct RoomDetailDTO: Codable {
    let id: Int
    let title: String
    let type: String
    let participants: [ParticipantDTO]

    func toDomain() -> RoomDetail {
        RoomDetail(
            id: id,
            title: title,
            type: type,
            participants: participants.map { $0.toDomain() }
        )
    }
}
