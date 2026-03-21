//
//  User.swift
//  ranchat
//

import Foundation

struct User {
    let id: String
    var name: String

    mutating func setName(_ newName: String) {
        name = newName
    }
}
