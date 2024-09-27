//
//  SceneDelegate.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 25/09/24.
//

import UIKit
import BackgroundTasks

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UIApplicationDelegate {

    var window: UIWindow?
    var logoutTimer: Timer?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        /// Register for remote notifications. This shows a permission dialog on first run, to
        /// show the dialog at a more appropriate time move this registration accordingly.
        ///
        setupNotification: do {
            UIApplication.shared.delegate = self
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
           
            UNUserNotificationCenter.current().requestAuthorization(options:    authOptions, completionHandler: { granted, error in
                if granted {
                    print("Permission granted")
                } else if let error = error {
                    print("Error: \(error)")
                }
            })

            UIApplication.shared.registerForRemoteNotifications()
        }
              
        window = UIWindow(windowScene: windowScene)
        
        let rootViewController = RootViewController()
        
        /// Programatically UI Layouting
        window?.rootViewController = UINavigationController(
            rootViewController: rootViewController
        )
      
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print(">>> sceneDidBecomeActive")
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        startLogoutTimerIfNeeded()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        print(">>> sceneDidEnterBackground")
        logoutTimer?.invalidate()
        scheduleBackgroundLogout()
    }

    func startLogoutTimerIfNeeded() {
        // Check if the login time is saved in UserDefaults
        if let loginTime = UserDefaults.standard.object(forKey: Constants.loginTimeKey) as? Date {
            let timeInterval = Date().timeIntervalSince(loginTime)

            if timeInterval >= 600 {
                // If 10 minutes has passed, logout immediately
                logoutUser()
            } else {
                // If not yet 10 minutes, start a timer for the remaining time
                let remainingTime = 600 - timeInterval
                logoutTimer = Timer.scheduledTimer(withTimeInterval: remainingTime, repeats: false) { _ in
                    self.logoutUser()
                }
            }
        }
    }
    
    func logoutUser() {
        UserDefaults.standard.removeObject(forKey: Constants.loginTimeKey)
        
        let content = UNMutableNotificationContent()
        content.title = "Logout"
        content.body = "Akun Anda sudah terlogout otomatis."

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "logoutNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error)")
            }
        }
    }
    
    func scheduleBackgroundLogout() {
        let request = BGAppRefreshTaskRequest(identifier: Constants.bgAppTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 600)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to submit background task: \(error)")
        }
    }
}

extension SceneDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
