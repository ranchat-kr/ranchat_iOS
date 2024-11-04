//
//  ranchatApp.swift
//  ranchat
//
//  Created by 김견 on 9/8/24.
//

import SwiftUI
import FirebaseCore
import Firebase
import FirebaseMessaging

@main
struct ranchatApp: App {
    private var webSocketHelper = WebSocketHelper()
    private var idHelper = IdHelper()
    private var networkMotinor = NetworkMonitor()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
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

class AppDelegate: NSObject, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            
            let authOption: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOption,
                completionHandler: {_, _ in}
            )
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // fcm 토근이 등록 되었을 때
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Logger.shared.log("AppDelegate", #function, "Device Token: \(deviceToken)")
        
        Messaging.messaging().apnsToken = deviceToken
    }
}

// Cloud Messaging
extension AppDelegate: MessagingDelegate {
    
    // fcm 등록 토근을 받았을 때
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Logger.shared.log("AppDelegate", #function, "token received: \(fcmToken ?? "")")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        
        Logger.shared.log("AppDelegate", #function, "dataDict: \(dataDict)")
    }
}

// User Notifications [AKA InApp Notification]
@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // 푸시 메세지가 앱이 켜져있을 때 나올 경우
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            Logger.shared.log("AppDelegate", #function, "messageID: \(messageID)")
        }
        
        Logger.shared.log("AppDelegate", #function, "userinfo: \(userInfo)")
        
        completionHandler([[.banner, .badge, .sound]])
    }
    
    // 푸시 알림 받았을 때
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            Logger.shared.log("AppDelegate", #function, "messageID: \(messageID)")
        }
        
        Logger.shared.log("AppDelegate", #function, "userinfo: \(userInfo)")
        
        completionHandler()
    }
}
