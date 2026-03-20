//
//  DefaultNotificationRepository.swift
//  ranchat
//

import Foundation
import Alamofire

class DefaultNotificationRepository: NotificationRepository {
    private let className = "DefaultNotificationRepository"
    private let headers: HTTPHeaders = ["Content-Type": "application/json", "Accept": "application/json"]

    func createNotifications(userId: String, allowsNotification: Bool, agentId: String, deviceName: String) async throws {
        let url = try getUrl(for: "https://\(DefaultData.shared.domain)/v1/app-notifications")
        let param: [String: Any] = [
            "userId": userId,
            "allowsNotification": allowsNotification,
            "agentId": agentId,
            "osType": "IOS",
            "deviceName": deviceName
        ]

        do {
            let response = try await AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(DefaultResponse.self)
                .value

            if response.status == Status.success.rawValue {
                Logger.shared.log(className, #function, "Success to create notifications")
                DefaultData.shared.saveToNotificationServerSuccess = true
            } else {
                Logger.shared.log(className, #function, "Failed to create notifications: \(response.message)", .error)
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            Logger.shared.log(className, #function, "Failed to create notifications: \(error.localizedDescription)", .error)
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }

    func updateAppNotifications(userId: String, agentId: String, allowsNotification: Bool) async throws {
        let url = try getUrl(for: "https://\(DefaultData.shared.domain)/v1/app-notifications")
        let param: [String: Any] = [
            "userId": userId,
            "agentId": agentId,
            "allowsNotification": allowsNotification
        ]

        do {
            let response = try await AF.request(url, method: .put, parameters: param, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(DefaultResponse.self)
                .value

            if response.status == Status.success.rawValue {
                Logger.shared.log(className, #function, "Success to update app notifications")
            } else {
                Logger.shared.log(className, #function, "Failed to update app notifications: \(response.message)", .error)
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            Logger.shared.log(className, #function, "Failed to update app notifications: \(error.localizedDescription)", .error)
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
