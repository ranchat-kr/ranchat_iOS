//
//  UpdateUserNameUseCase.swift
//  ranchat
//

import Foundation

protocol UpdateUserNameUseCase {
    func execute(userId: String, name: String) async throws
}

final class DefaultUpdateUserNameUseCase: UpdateUserNameUseCase {
    private let userRepository: UserRepository

    init(userRepository: UserRepository = DefaultUserRepository()) {
        self.userRepository = userRepository
    }

    func execute(userId: String, name: String) async throws {
        try await userRepository.updateUserName(userId: userId, name: name)
    }
}
