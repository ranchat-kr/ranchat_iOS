//
//  ContentView.swift
//  ranchat
//
//  Created by 김견 on 9/8/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(WebSocketHelper.self) var webSocketHelper
    @Environment(NetworkMonitor.self) var networkMonitor
    
    init () {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        HomeView()
            .onChange(of: networkMonitor.isConnected) { oldValue, newValue in
                if oldValue == false && newValue == true {  // 네트워크가 연결 되었을 때
                    do {
                        try webSocketHelper.connectToWebSocket()
                    } catch {
                        Logger.shared.log("ContentView", #function, "Failed to connect to WebSocket", .error)
                    }
                    
                    if !DefaultData.shared.saveToNotificationServerSuccess {
                        Task {
                            try await ApiHelper.shared.createNotifications(
                                allowsNotification: DefaultData.shared.permissionForNotification ?? false,
                                agentId: DefaultData.shared.agentId ?? "",
                                deviceName: UIDevice.current.name
                            )
                        }
                    }
                }
            }
    }
}

#Preview {
    ContentView()
}
