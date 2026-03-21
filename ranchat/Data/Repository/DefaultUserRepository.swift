//
//  DefaultUserRepository.swift
//  ranchat
//

import Foundation
import Alamofire

final class DefaultUserRepository: UserRepository {
    private let className = "DefaultUserRepository"
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient = AlamofireNetworkClient()) {
        self.networkClient = networkClient
    }

    func createUser(id: String, name: String) async throws {
        let url = try getUrl(for: "https://\(DefaultData.shared.domain)/v1/users")
        let param: [String: Any] = ["id": id, "name": name]

        let response: ApiResponseDTO<Bool> = try await networkClient.request(url: url, method: .post, params: param)
        if response.status != Status.success.rawValue {
            Logger.shared.log(className, #function, "Failed to create user: \(response.message)", .error)
            throw ApiHelperError.networkError(response.message)
        }
        Logger.shared.log(className, #function, "Success to create user")
    }

    func getUser(userId: String) async throws -> User {
        let url = try getUrl(for: "https://\(DefaultData.shared.domain)/v1/users/\(userId)")

        let response: ApiResponseDTO<UserDTO> = try await networkClient.request(url: url, method: .get, params: nil)
        if response.status == Status.success.rawValue {
            guard let dto = response.data else {
                throw ApiHelperError.responseDataError
            }
            Logger.shared.log(className, #function, "Success to get user")
            return dto.toDomain()
        } else {
            Logger.shared.log(className, #function, "Failed to get user: \(response.message)", .error)
            throw ApiHelperError.networkError(response.message)
        }
    }

    func updateUserName(userId: String, name: String) async throws {
        let url = try getUrl(for: "https://\(DefaultData.shared.domain)/v1/users/\(userId)")
        let param: [String: Any] = ["name": name]

        let response: ApiResponseDTO<Bool> = try await networkClient.request(url: url, method: .put, params: param)
        if response.status != Status.success.rawValue {
            Logger.shared.log(className, #function, "Failed to update user name: \(response.message)", .error)
            throw ApiHelperError.networkError(response.message)
        }
        Logger.shared.log(className, #function, "Success to update user name")
    }

    private func getUrl(for path: String) throws -> URL {
        guard let url = URL(string: path) else {
            throw ApiHelperError.invalidURLError
        }
        return url
    }
}
