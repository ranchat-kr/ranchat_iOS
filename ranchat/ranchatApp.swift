//
//  ranchatApp.swift
//  ranchat
//
//  Created by 김견 on 9/8/24.
//

import SwiftUI
import SwiftData
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct ranchatApp: App {
    private var webSocketHelper = WebSocketHelper()
    private var idHelper = IdHelper()
    private var networkMotinor = NetworkMonitor()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            User.self
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    ApiHelper.shared.setIdHelper(idHelper: idHelper)
                    webSocketHelper.setIdHelper(idHelper: idHelper)
                }
                .preferredColorScheme(.dark)
                .environment(webSocketHelper)
                .environment(idHelper)
                .environment(networkMotinor)
        }
//        .modelContainer(sharedModelContainer)
    }
}
