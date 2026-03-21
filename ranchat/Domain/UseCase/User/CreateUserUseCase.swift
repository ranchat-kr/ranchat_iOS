//
//  CreateUserUseCase.swift
//  ranchat
//

import Foundation

protocol CreateUserUseCase {
    func execute(id: String, name: String) async throws
}

final class DefaultCreateUserUseCase: CreateUserUseCase {
    private let userRepository: UserRepository

    init(userRepository: UserRepository = DefaultUserRepository()) {
        self.userRepository = userRepository
    }

    func execute(id: String, name: String) async throws {
        try await userRepository.createUser(id: id, name: name)
    }
}
