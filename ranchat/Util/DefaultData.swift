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
    
    @AppStorage("permissionForNotification") var permissionForNotification: Bool? // 앱 권한
    @AppStorage("isNotificationEnabled") var isNotificationEnabled: Bool = true // 설정 화면에서의 알림 설정
    @AppStorage("agentId") var agentId: String?
    @AppStorage("saveToNotificationServerSuccess") var saveToNotificationServerSuccess: Bool = false
}
