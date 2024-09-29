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
    
    private var logoutTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
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
    
    func register() {
        isLoading = true
        
        let userManager = UserManager.shared.getAuth0Configuration()
        
        authService.register(userManager.clientId ?? "", email, password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] result in
                switch result {
                case let .success(response):
                    // auto login
                    self?.login()
                case let .failure(error):
                    self?.errorMessage = error.message
                }
            }
            .store(in: &cancellables)
    }
    
    func login() {
        isLoading = true
        
        let userManager = UserManager.shared.getAuth0Configuration()
        
        authService.login(userManager.clientId ?? "", email, password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] result in
                switch result {
                case let .success(response):
                    KeychainManager.shared.saveAccessToken(token: response.accessToken)
                    self?.userInfo()
                case let .failure(error):
                    self?.errorMessage = error.errorDescription
                }
            }
            .store(in: &cancellables)
    }

    func userInfo() {
        authService.getUserInfo()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] result in
                switch result {
                case let .success(response):
                    self?.saveStoredUserData(StoredUserData(
                        email: response.email,
                        name: response.nickname
                    ))
                    self?.startAutoLogoutTimer()
                    self?.isLoggedIn = true
                case let .failure(error):
                    self?.errorMessage = error.localizedDescription
                }
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
        logoutTimer?.invalidate()
        
        logoutTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.checkLogoutStatus()
        }
    }
    
    private func checkLogoutStatus() {
        if let lastLoginTime = UserDefaults.standard.object(forKey:  Constants.lastLoginTimeKey) as? Date {
            let elapsedTime = Date().timeIntervalSince(lastLoginTime)
            
            if elapsedTime > Constants.loginDuration {
                logoutTimer?.invalidate()
                
                UserManager.shared.logout(shouldNotif: true)
            }
        }
    }
}
