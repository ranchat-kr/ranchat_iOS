//
//  UserDTO.swift
//  ranchat
//

import Foundation

struct UserDTO: Codable {
    let id: String
    let name: String

    func toDomain() -> User {
        User(id: id, name: name)
    }
}
