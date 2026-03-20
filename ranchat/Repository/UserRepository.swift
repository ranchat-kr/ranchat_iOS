//
//  UserRepository.swift
//  ranchat
//

protocol UserRepository {
    func createUser(id: String, name: String) async throws
    func getUser(userId: String) async throws -> UserData
    func updateUserName(userId: String, name: String) async throws
}
