//
//  LoginViewModel.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 28/09/24.
//

import Foundation
import Combine

class LoginViewModel {
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var isLoginEnabled: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isLoggedIn: Bool = false
    
    private var logoutTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        validateInputs()
    }
    
    private func validateInputs() {
        Publishers.CombineLatest($email, $password)
            .map { email, password in
//                return email.isValidEmail() && !password.isEmpty
                return !password.isEmpty
            }
            .assign(to: &$isLoginEnabled)
    }
    
    func login() {
        isLoading = true
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            DispatchQueue.main.async {
                self.isLoading = false
                
                if self.password == "123" {
                    self.saveLoginTime()
                    self.saveStoredUserData(StoredUserData(email: "email", name: "ichsan"))
                    self.startAutoLogoutTimer()
                    
                    self.isLoggedIn = true
                } else {
                    self.errorMessage = "Invalid email or password"
                }
            }
        }
    }
    
    private func saveLoginTime() {
        let currentTime = Date()
        UserDefaults.standard.set(currentTime, forKey: Constants.lastLoginTimeKey)
    }
    
    private func saveStoredUserData(_ user: StoredUserData) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            UserDefaults.standard.set(encoded, forKey: Constants.loggedInUserDataKey)
        }
    }
    
    private func startAutoLogoutTimer() {
        print(">>> startAutoLogoutTimer")
        logoutTimer?.invalidate()
        
        logoutTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.checkLogoutStatus()
        }
    }
    
    private func checkLogoutStatus() {
        if let lastLoginTime = UserDefaults.standard.object(forKey:  Constants.lastLoginTimeKey) as? Date {
            let elapsedTime = Date().timeIntervalSince(lastLoginTime)
            
            print(">>> checkLogoutStatus -> elapsedTime: \(elapsedTime)")
            
            if elapsedTime > Constants.loginDuration {
                logoutTimer?.invalidate()
                
                logout()
            }
        }
    }
}
