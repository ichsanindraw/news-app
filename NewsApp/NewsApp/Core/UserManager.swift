//
//  UserManager.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 28/09/24.
//

import Combine
import Foundation
import UserNotifications
import UIKit

class UserManager {
    static let shared = UserManager(authService: AuthService())
    private var cancellables = Set<AnyCancellable>()
    private let authService: AuthServiceProtocol

    private init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    func logout(shouldNotif: Bool, completion: ((Result<Void, Error>) -> Void)? = nil) {
        authService.logout()
            .receive(on: DispatchQueue.main)
            .sink { inCompletion in
                switch inCompletion {
                case .finished:
                    break
                case let .failure(error):
                    completion?(.failure(error))
                    break
                }
            } receiveValue: { [weak self] result in
                switch result {
                case .success:
                    self?.cleanup()
                    completion?(.success(()))
                    
                    if shouldNotif {
                        DispatchQueue.main.async { [weak self] in
                            self?.sendLogoutNotification()
                        }
                    } else {
                        self?.goToLoginPage()
                    }
                    
                   
                case let .failure(error):
                    completion?(.failure(error))
                }
                
            }
            .store(in: &cancellables)
    }
    
    private func cleanup() {
        KeychainManager.shared.deleteAccessToken()
        UserDefaults.standard.removeObject(forKey: Constants.lastLoginTimeKey)
        UserDefaults.standard.removeObject(forKey: Constants.loggedInUserDataKey)
    }
    
    func getUserData() -> StoredUserData? {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: Constants.loggedInUserDataKey) {
            do {
                let userData = try decoder.decode(StoredUserData.self, from: data)
                return userData
            } catch {
                print("Error decoding user data: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    func getAuth0Configuration() -> (clientId: String?, domain: String?) {
        guard let path = Bundle.main.path(forResource: "Auth0", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path) else {
            return (nil, nil)
        }

        let clientId = plist["ClientId"] as? String
        let domain = plist["Domain"] as? String

        return (clientId, domain)
    }
    
    private func sendLogoutNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Session Expired"
        content.body = "Akun Anda sudah terlogout secara otomatis setelah 10 menit."
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "logoutNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                print("Failed to send logout notification: \(error)")
            } else {
                print("Logout notification sent successfully.")
                // Push the login screen
                self?.goToLoginPage()
            }
        }
    }
    
    private func goToLoginPage() {
        DispatchQueue.main.async {
            guard let sceneDelegate = UIApplication.shared.delegate as? SceneDelegate
            else { return }
            
            // Initialize and set LoginViewController
            let loginViewController = LoginViewController()
            sceneDelegate.window?.rootViewController = UINavigationController(
                rootViewController: loginViewController
            )
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }
}
