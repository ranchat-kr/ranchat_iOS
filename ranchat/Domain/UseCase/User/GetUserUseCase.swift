//
//  GetUserUseCase.swift
//  ranchat
//

import Foundation

protocol GetUserUseCase {
    func execute(userId: String) async throws -> User
}

final class DefaultGetUserUseCase: GetUserUseCase {
    private let userRepository: UserRepository

    init(userRepository: UserRepository = DefaultUserRepository()) {
        self.userRepository = userRepository
    }

    func execute(userId: String) async throws -> User {
        try await userRepository.getUser(userId: userId)
    }
}
