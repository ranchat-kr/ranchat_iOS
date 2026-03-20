//
//  DefaultRoomRepository.swift
//  ranchat
//

import Foundation
import Alamofire

class DefaultRoomRepository: RoomRepository {
    private let className = "DefaultRoomRepository"
    private let headers: HTTPHeaders = ["Content-Type": "application/json", "Accept": "application/json"]

    func getRooms(userId: String, page: Int, size: Int) async throws -> RoomDataList {
        let url = try getUrl(for: "https://\(DefaultData.shared.domain)/v1/rooms?page=\(page)&size=\(size)&userId=\(userId)")

        do {
            let response = try await AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(RoomDataList.self)
                .value

            if response.status == Status.success.rawValue {
                Logger.shared.log(className, #function, "Success to get rooms")
                return response
            } else {
                Logger.shared.log(className, #function, "Failed to get rooms: \(response.message)", .error)
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            Logger.shared.log(className, #function, "Failed to get rooms: \(error.localizedDescription)", .error)
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }

    func checkRoomExist(userId: String) async throws -> Bool {
        let url = try getUrl(for: "https://\(DefaultData.shared.domain)/v1/rooms/exists-by-userId?userId=\(userId)")

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
                case .boolValue(let boolValue):
                    Logger.shared.log(className, #function, "Successfully checked room exist: \(boolValue)")
                    return boolValue
                default:
                    throw ApiHelperError.responseDataError
                }
            } else {
                Logger.shared.log(className, #function, "Failed to check room exist: \(response.message)", .error)
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            Logger.shared.log(className, #function, "Failed to check room exist: \(error.localizedDescription)", .error)
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }

    func getRoomDetail(userId: String, roomId: String) async throws -> RoomDetailData {
        let url = try getUrl(for: "https://\(DefaultData.shared.domain)/v1/rooms/\(roomId)?userId=\(userId)")

        do {
            let response = try await AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(RoomDetailDataResponse.self)
                .value

            if response.status == Status.success.rawValue {
                Logger.shared.log(className, #function, "Success to get room detail")
                return response.data
            } else {
                Logger.shared.log(className, #function, "Failed to get room detail: \(response.message)", .error)
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            Logger.shared.log(className, #function, "Failed to get room detail: \(error.localizedDescription)", .error)
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }

    func createRoom(userId: String) async throws -> String {
        let url = try getUrl(for: "https://\(DefaultData.shared.domain)/v1/rooms")
        let param: [String: Any] = [
            "userIds": [userId],
            "roomType": "GPT"
        ]

        do {
            let response = try await AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(DefaultResponse.self)
                .value

            if response.status == Status.success.rawValue {
                guard let responseData = response.data else {
                    throw ApiHelperError.responseDataError
                }
                switch responseData {
                case .intValue(let intValue):
                    Logger.shared.log(className, #function, "Success to create room: \(intValue)")
                    return String(intValue)
                default:
                    throw ApiHelperError.responseDataError
                }
            } else {
                Logger.shared.log(className, #function, "Failed to create room: \(response.message)", .error)
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            Logger.shared.log(className, #function, "Failed to create room: \(error.localizedDescription)", .error)
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
