//
//  DefaultRoomRepository.swift
//  ranchat
//

import Foundation
import Alamofire

final class DefaultRoomRepository: RoomRepository {
    private let className = "DefaultRoomRepository"
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient = AlamofireNetworkClient()) {
        self.networkClient = networkClient
    }

    func getRooms(userId: String, page: Int, size: Int) async throws -> RoomPage {
        let url = try getUrl(for: "https://\(DefaultData.shared.domain)/v1/rooms?page=\(page)&size=\(size)&userId=\(userId)")

        let response: ApiResponseDTO<RoomPageDTO> = try await networkClient.request(url: url, method: .get, params: nil)
        if response.status == Status.success.rawValue {
            guard let dto = response.data else {
                throw ApiHelperError.responseDataError
            }
            Logger.shared.log(className, #function, "Success to get rooms")
            return dto.toDomain()
        } else {
            Logger.shared.log(className, #function, "Failed to get rooms: \(response.message)", .error)
            throw ApiHelperError.networkError(response.message)
        }
    }

    func checkRoomExist(userId: String) async throws -> Bool {
        let url = try getUrl(for: "https://\(DefaultData.shared.domain)/v1/rooms/exists-by-userId?userId=\(userId)")

        let response: ApiResponseDTO<Bool> = try await networkClient.request(url: url, method: .get, params: nil)
        if response.status == Status.success.rawValue {
            guard let boolValue = response.data else {
                throw ApiHelperError.responseDataError
            }
            Logger.shared.log(className, #function, "Successfully checked room exist: \(boolValue)")
            return boolValue
        } else {
            Logger.shared.log(className, #function, "Failed to check room exist: \(response.message)", .error)
            throw ApiHelperError.networkError(response.message)
        }
    }

    func getRoomDetail(userId: String, roomId: String) async throws -> RoomDetail {
        let url = try getUrl(for: "https://\(DefaultData.shared.domain)/v1/rooms/\(roomId)?userId=\(userId)")

        let response: ApiResponseDTO<RoomDetailDTO> = try await networkClient.request(url: url, method: .get, params: nil)
        if response.status == Status.success.rawValue {
            guard let dto = response.data else {
                throw ApiHelperError.responseDataError
            }
            Logger.shared.log(className, #function, "Success to get room detail")
            return dto.toDomain()
        } else {
            Logger.shared.log(className, #function, "Failed to get room detail: \(response.message)", .error)
            throw ApiHelperError.networkError(response.message)
        }
    }

    func createRoom(userId: String) async throws -> String {
        let url = try getUrl(for: "https://\(DefaultData.shared.domain)/v1/rooms")
        let param: [String: Any] = [
            "userIds": [userId],
            "roomType": "GPT"
        ]

        let response: ApiResponseDTO<Int> = try await networkClient.request(url: url, method: .post, params: param)
        if response.status == Status.success.rawValue {
            guard let intValue = response.data else {
                throw ApiHelperError.responseDataError
            }
            Logger.shared.log(className, #function, "Success to create room: \(intValue)")
            return String(intValue)
        } else {
            Logger.shared.log(className, #function, "Failed to create room: \(response.message)", .error)
            throw ApiHelperError.networkError(response.message)
        }
    }

    private func getUrl(for path: String) throws -> URL {
        guard let url = URL(string: path) else {
            throw ApiHelperError.invalidURLError
        }
        return url
    }
}
