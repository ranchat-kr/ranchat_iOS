//
//  CreateNotificationUseCase.swift
//  ranchat
//

import Foundation

protocol CreateNotificationUseCase {
    func execute(userId: String, allowsNotification: Bool, agentId: String, deviceName: String) async throws
}

final class DefaultCreateNotificationUseCase: CreateNotificationUseCase {
    private let notificationRepository: NotificationRepository

    init(notificationRepository: NotificationRepository = DefaultNotificationRepository()) {
        self.notificationRepository = notificationRepository
    }

    func execute(userId: String, allowsNotification: Bool, agentId: String, deviceName: String) async throws {
        try await notificationRepository.createNotifications(
            userId: userId,
            allowsNotification: allowsNotification,
            agentId: agentId,
            deviceName: deviceName
        )
    }
}
