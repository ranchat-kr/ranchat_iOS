//
//  UpdateNotificationUseCase.swift
//  ranchat
//

import Foundation

protocol UpdateNotificationUseCase {
    func execute(userId: String, agentId: String, allowsNotification: Bool) async throws
}

final class DefaultUpdateNotificationUseCase: UpdateNotificationUseCase {
    private let notificationRepository: NotificationRepository

    init(notificationRepository: NotificationRepository = DefaultNotificationRepository()) {
        self.notificationRepository = notificationRepository
    }

    func execute(userId: String, agentId: String, allowsNotification: Bool) async throws {
        try await notificationRepository.updateAppNotifications(
            userId: userId,
            agentId: agentId,
            allowsNotification: allowsNotification
        )
    }
}
