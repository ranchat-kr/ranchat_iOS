//
//  NotificationRepository.swift
//  ranchat
//

import Foundation

protocol NotificationRepository {
    func createNotifications(userId: String, allowsNotification: Bool, agentId: String, deviceName: String) async throws
    func updateAppNotifications(userId: String, agentId: String, allowsNotification: Bool) async throws
}
