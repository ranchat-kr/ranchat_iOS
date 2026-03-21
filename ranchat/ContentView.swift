//
//  ContentView.swift
//  ranchat
//

import SwiftUI

struct ContentView: View {
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
                if oldValue == false && newValue == true {
                    if !DefaultData.shared.saveToNotificationServerSuccess,
                       let userId = KeychainHelper.shared.getUserId() {
                        Task {
                            do {
                                try await DefaultCreateNotificationUseCase().execute(
                                    userId: userId,
                                    allowsNotification: DefaultData.shared.permissionForNotification ?? false,
                                    agentId: DefaultData.shared.agentId ?? "",
                                    deviceName: UIDevice.current.name
                                )
                            } catch {
                                Logger.shared.log("ContentView", #function, "Failed to create notifications: \(error.localizedDescription)", .error)
                            }
                        }
                    }
                }
            }
    }
}

#Preview {
    ContentView()
}
