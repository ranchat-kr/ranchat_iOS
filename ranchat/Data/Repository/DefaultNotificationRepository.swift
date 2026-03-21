//
//  DefaultNotificationRepository.swift
//  ranchat
//

import Foundation
import Alamofire

final class DefaultNotificationRepository: NotificationRepository {
    private let className = "DefaultNotificationRepository"
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient = AlamofireNetworkClient()) {
        self.networkClient = networkClient
    }

    func createNotifications(userId: String, allowsNotification: Bool, agentId: String, deviceName: String) async throws {
        let url = try getUrl(for: "https://\(DefaultData.shared.domain)/v1/app-notifications")
        let param: [String: Any] = [
            "userId": userId,
            "allowsNotification": allowsNotification,
            "agentId": agentId,
            "osType": "IOS",
            "deviceName": deviceName
        ]

        let response: ApiResponseDTO<Bool> = try await networkClient.request(url: url, method: .post, params: param)
        if response.status == Status.success.rawValue {
            Logger.shared.log(className, #function, "Success to create notifications")
            DefaultData.shared.saveToNotificationServerSuccess = true
        } else {
            Logger.shared.log(className, #function, "Failed to create notifications: \(response.message)", .error)
            throw ApiHelperError.networkError(response.message)
        }
    }

    func updateAppNotifications(userId: String, agentId: String, allowsNotification: Bool) async throws {
        let url = try getUrl(for: "https://\(DefaultData.shared.domain)/v1/app-notifications")
        let param: [String: Any] = [
            "userId": userId,
            "agentId": agentId,
            "allowsNotification": allowsNotification
        ]

        let response: ApiResponseDTO<Bool> = try await networkClient.request(url: url, method: .put, params: param)
        if response.status != Status.success.rawValue {
            Logger.shared.log(className, #function, "Failed to update app notifications: \(response.message)", .error)
            throw ApiHelperError.networkError(response.message)
        }
        Logger.shared.log(className, #function, "Success to update app notifications")
    }

    private func getUrl(for path: String) throws -> URL {
        guard let url = URL(string: path) else {
            throw ApiHelperError.invalidURLError
        }
        return url
    }
}
