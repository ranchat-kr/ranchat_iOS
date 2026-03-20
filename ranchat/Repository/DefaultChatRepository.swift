//
//  DefaultChatRepository.swift
//  ranchat
//

import Foundation
import Alamofire

class DefaultChatRepository: ChatRepository {
    private let className = "DefaultChatRepository"
    private let headers: HTTPHeaders = ["Content-Type": "application/json", "Accept": "application/json"]

    func getMessages(roomId: String, page: Int, size: Int) async throws -> MessagesListResponseData {
        let url = try getUrl(for: "https://\(DefaultData.shared.domain)/v1/rooms/\(roomId)/messages?page=\(page)&size=\(size)")

        do {
            let response = try await AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(MessageListResponse.self)
                .value

            if response.status == Status.success.rawValue {
                Logger.shared.log(className, #function, "Success to get messages")
                return response.data
            } else {
                Logger.shared.log(className, #function, "Failed to get messages: \(response.message)", .error)
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            Logger.shared.log(className, #function, "Failed to get messages: \(error.localizedDescription)", .error)
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }

    func reportUser(roomId: String, reporterId: String, reportedUserId: String, reportType: String, reportReason: String) async throws {
        let url = try getUrl(for: "https://\(DefaultData.shared.domain)/v1/reports")
        let param: [String: Any] = [
            "roomId": roomId,
            "reporterId": reporterId,
            "reportedUserId": reportedUserId,
            "reportType": reportType,
            "reportReason": reportReason
        ]

        do {
            let response = try await AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(DefaultResponse.self)
                .value

            if response.status == Status.success.rawValue {
                Logger.shared.log(className, #function, "Success to report user")
            } else {
                Logger.shared.log(className, #function, "Failed to report user: \(response.message)", .error)
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            Logger.shared.log(className, #function, "Failed to report user: \(error.localizedDescription)", .error)
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
