//
//  DefaultData.swift
//  ranchat
//
//  Created by 김견 on 9/14/24.
//

import SwiftUI

class DefaultData {
    static let shared = DefaultData()
    
    let domain = "api.ranchat.net"
    
    //@AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    @AppStorage("permissionForNotification") var permissionForNotification: Bool? // 앱 권한
    @AppStorage("isNotificationEnabled") var isNotificationEnabled: Bool = true // 설정 화면에서의 알림 설정
    @AppStorage("agentId") var agentId: String?
    
    func getPermissionForNotification() {
        if self.permissionForNotification == nil {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                self.permissionForNotification = settings.authorizationStatus == .authorized
                self.isNotificationEnabled = self.permissionForNotification ?? false
            }
            Task {
                do {
                    try await ApiHelper.shared.createNotifications(
                        allowsNotification: self.permissionForNotification ?? false,
                        agentId: self.agentId ?? "",
                        osType: "IOS",
                        deviceName: UIDevice.current.name
                    )
                } catch {
                    
                }
            }
        }
    }
}
