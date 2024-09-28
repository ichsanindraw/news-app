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
    
    @Published var isEmailValid: Bool = false
    @Published var isButtonEnabled: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isLoggedIn: Bool = false
    
    @Published var accessToken: String = ""
    
    private var logoutTimer: Timer?
    private let networkManager = NetworkManager()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        validateInputs()
    }
    
    private func validateInputs() {
        Publishers.CombineLatest($email, $password)
            .map { email, password in
                return !email.isEmpty && !password.isEmpty
            }
            .assign(to: &$isButtonEnabled)
        
        $email
            .map { isValidEmail($0) }
            .assign(to: \.isEmailValid, on: self)
            .store(in: &cancellables)
    }
    
    func signUp() {
        isLoading = true
        
        networkManager.signup(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.errorMessage = error.localizedDescription
                    print("Register error: \(error)")
                }
            } receiveValue: { [weak self] result in
                switch result {
                case let .success(response):
                    print("Register successful: \(response)")
                    // auto login
                    self?.signIn()
                case let .failure(error):
                    self?.errorMessage = error.message
                }
            }
            .store(in: &cancellables)
    }
    
    func signIn() {
        isLoading = true
        
        networkManager.signIn(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isLoading = false
                    break
                case let .failure(error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] result in
                switch result {
                case let .success(response):
                    print("Login successful: \(response)")
//                    let data = try decodeJWT(response.idToken)
//                    print("data: \(data)")
//                    self?.saveStoredUserData(StoredUserData(email: "email", name: "ichsan"))
//                    self?.startAutoLogoutTimer()
//                    self?.isLoggedIn = true
                    KeychainManager.shared.saveAccessToken(token: response.accessToken)
                    self?.userInfo()
                case let .failure(error):
                    self?.errorMessage = error.errorDescription
                }
            }
            .store(in: &cancellables)
    }
    
    func userInfo() {
        networkManager.userInfo()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
//                    self?.isLoading = false
                    break
                case let .failure(error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] response in
                print(">>> get user info success: \(response)")
                self?.saveStoredUserData(StoredUserData(email: "email", name: response.nickname))
                self?.startAutoLogoutTimer()
                self?.isLoggedIn = true
            }
            .store(in: &cancellables)

    }
    
    private func saveStoredUserData(_ user: StoredUserData) {
        // save current time for auto logout purpose
        UserDefaults.standard.set(Date(), forKey: Constants.lastLoginTimeKey)
        
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
                
                UserManager.shared.logout(completion: { result in
                    print(">>> result: \(result)")
                })
            }
        }
    }
}
