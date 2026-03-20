//
//  DefaultUserRepository.swift
//  ranchat
//

import Foundation
import Alamofire

class DefaultUserRepository: UserRepository {
    private let className = "DefaultUserRepository"
    private let headers: HTTPHeaders = ["Content-Type": "application/json", "Accept": "application/json"]

    func createUser(id: String, name: String) async throws {
        let url = try getUrl(for: "https://\(DefaultData.shared.domain)/v1/users")
        let param: [String: Any] = ["id": id, "name": name]

        do {
            let response = try await AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(DefaultResponse.self)
                .value

            if response.status == Status.success.rawValue {
                Logger.shared.log(className, #function, "Success to create user")
            } else {
                Logger.shared.log(className, #function, "Failed to create user: \(response.message)", .error)
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            Logger.shared.log(className, #function, "Failed to create user: \(error.localizedDescription)", .error)
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }

    func getUser(userId: String) async throws -> UserData {
        let url = try getUrl(for: "https://\(DefaultData.shared.domain)/v1/users/\(userId)")

        do {
            let response = try await AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(DefaultResponse.self)
                .value

            if response.status == Status.success.rawValue {
                guard let responseData = response.data else {
                    throw ApiHelperError.responseDataError
                }
                switch responseData {
                case .userDataValue(let userData):
                    Logger.shared.log(className, #function, "Success to get user")
                    return userData
                default:
                    throw ApiHelperError.responseDataError
                }
            } else {
                Logger.shared.log(className, #function, "Failed to get user: \(response.message)", .error)
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            Logger.shared.log(className, #function, "Failed to get user: \(error.localizedDescription)", .error)
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }

    func updateUserName(userId: String, name: String) async throws {
        let url = try getUrl(for: "https://\(DefaultData.shared.domain)/v1/users/\(userId)")
        let param: [String: Any] = ["name": name]

        do {
            let response = try await AF.request(url, method: .put, parameters: param, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(DefaultResponse.self)
                .value

            if response.status == Status.success.rawValue {
                Logger.shared.log(className, #function, "Success to update user name")
            } else {
                Logger.shared.log(className, #function, "Failed to update user name: \(response.message)", .error)
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            Logger.shared.log(className, #function, "Failed to update user name: \(error.localizedDescription)", .error)
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }

    private func getUrl(for path: String) throws -> URL {
        guard let url = URL(string: path) else {
            throw ApiHelperError.invalidURLError
        }
        return url
    }
}
