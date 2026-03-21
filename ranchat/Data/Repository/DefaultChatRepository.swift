//
//  DefaultChatRepository.swift
//  ranchat
//

import Foundation
import Alamofire

final class DefaultChatRepository: ChatRepository {
    private let className = "DefaultChatRepository"
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient = AlamofireNetworkClient()) {
        self.networkClient = networkClient
    }

    func getMessages(roomId: String, page: Int, size: Int) async throws -> MessagePage {
        let url = try APIEndpoint.messages(roomId: roomId, page: page, size: size)

        let response: ApiResponseDTO<MessagePageDTO> = try await networkClient.request(url: url, method: .get, params: nil)
        if response.status == Status.success.rawValue {
            guard let dto = response.data else {
                throw ApiHelperError.responseDataError
            }
            Logger.shared.log(className, #function, "Success to get messages")
            return dto.toDomain()
        } else {
            Logger.shared.log(className, #function, "Failed to get messages: \(response.message)", .error)
            throw ApiHelperError.networkError(response.message)
        }
    }

    func reportUser(roomId: String, reporterId: String, reportedUserId: String, reportType: String, reportReason: String) async throws {
        let url = try APIEndpoint.reports()
        let param: [String: Any] = [
            "roomId": roomId,
            "reporterId": reporterId,
            "reportedUserId": reportedUserId,
            "reportType": reportType,
            "reportReason": reportReason
        ]

        let response: ApiResponseDTO<Bool> = try await networkClient.request(url: url, method: .post, params: param)
        if response.status != Status.success.rawValue {
            Logger.shared.log(className, #function, "Failed to report user: \(response.message)", .error)
            throw ApiHelperError.networkError(response.message)
        }
        Logger.shared.log(className, #function, "Success to report user")
    }
}
