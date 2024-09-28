//
//  AppDelegate.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 25/09/24.
//

import UIKit
import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Register the background task when the app launches
//        registerBackgroundTask()
        
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func registerBackgroundTask() {
        // Register a background task to handle logout
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Constants.bgAppTaskIdentifier, using: nil) { task in
            self.handleBackgroundLogout(task: task as! BGAppRefreshTask)
        }
    }
    
    func handleBackgroundLogout(task: BGAppRefreshTask) {
        // This function will be called when the background task is triggered
        checkAutoLogout()
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        task.setTaskCompleted(success: true)
    }

    func checkAutoLogout() {
        if let loginTime = UserDefaults.standard.object(forKey: Constants.lastLoginTimeKey) as? Date {
            let currentTime = Date()
            let timeInterval = currentTime.timeIntervalSince(loginTime)

            if timeInterval > 600 {
                // If 10 minutes have passed, logout the user
                logoutUser()
            }
        }
    }
    
    func logoutUser() {
        // Perform logout and clear login time
        UserDefaults.standard.removeObject(forKey: Constants.lastLoginTimeKey)
        
        // Optionally, notify the user via push notification
        print("User logged out due to inactivity.")
        sendLogoutNotification()
    }

}


//enum SectionGallery {
//    case video(id: Int, item: [String])
//}
//
//enum SectionItemGallery {
//    case test
//}
