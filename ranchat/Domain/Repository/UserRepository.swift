//
//  UserRepository.swift
//  ranchat
//

import Foundation

protocol UserRepository {
    func createUser(id: String, name: String) async throws
    func getUser(userId: String) async throws -> User
    func updateUserName(userId: String, name: String) async throws
}
