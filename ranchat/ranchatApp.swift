//
//  ranchatApp.swift
//  ranchat
//

import SwiftUI
import FirebaseCore
import Firebase
import FirebaseMessaging

@main
struct ranchatApp: App {
    private var webSocketHelper = WebSocketHelper()
    private var idHelper = IdHelper()
    private var networkMonitor = NetworkMonitor()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environment(webSocketHelper)
                .environment(idHelper)
                .environment(networkMonitor)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.message_id"
    private let createNotificationUseCase: any CreateNotificationUseCase = DefaultCreateNotificationUseCase()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self

            let authOption: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOption
            ) { granted, error in
                Logger.shared.log("AppDelegate", #function, "granted: \(granted) requestAuthorization: ")
                DefaultData.shared.permissionForNotification = granted
                if let error {
                    Logger.shared.log("AppDelegate", #function, "Failed to request authorization: \(error.localizedDescription)")
                } else if !DefaultData.shared.saveToNotificationServerSuccess {
                    if let token = DefaultData.shared.agentId,
                       let userId = KeychainHelper.shared.getUserId() {
                        Task {
                            do {
                                try await self.createNotificationUseCase.execute(
                                    userId: userId,
                                    allowsNotification: granted,
                                    agentId: token,
                                    deviceName: UIDevice.current.name
                                )
                            } catch {
                                Logger.shared.log("AppDelegate", #function, "Failed to create notifications: \(error.localizedDescription)", .error)
                            }
                        }
                    }
                }
            }
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()

        Messaging.messaging().delegate = self

        return true
    }

    // fcm 토큰이 등록 되었을 때
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Logger.shared.log("AppDelegate", #function, "Device Token: \(deviceToken.base64EncodedString())")

        Messaging.messaging().apnsToken = deviceToken
    }
}

// Cloud Messaging
extension AppDelegate: MessagingDelegate {

    // fcm 등록 토큰을 받았을 때
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Logger.shared.log("AppDelegate", #function, "token received: \(fcmToken ?? "")")

        let dataDict: [String: String] = ["token": fcmToken ?? ""]

        Logger.shared.log("AppDelegate", #function, "dataDict: \(dataDict)")

        if DefaultData.shared.saveToNotificationServerSuccess && DefaultData.shared.agentId == fcmToken {
            return
        }

        if let permissionForNotification = DefaultData.shared.permissionForNotification,
           DefaultData.shared.agentId != fcmToken,
           let userId = KeychainHelper.shared.getUserId() {
            Logger.shared.log("AppDelegate", #function, "permission, token, createNotifications")
            Task {
                do {
                    try await createNotificationUseCase.execute(
                        userId: userId,
                        allowsNotification: permissionForNotification,
                        agentId: fcmToken ?? "",
                        deviceName: UIDevice.current.name
                    )
                } catch {
                    Logger.shared.log("AppDelegate", #function, "Failed to create notifications: \(error.localizedDescription)", .error)
                }
            }
        }
        DefaultData.shared.agentId = fcmToken
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

        completionHandler([])
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
