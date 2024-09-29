//
//  AuthService.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 29/09/24.
//

import Combine

protocol AuthServiceProtocol {
    func login(
        _ clientId: String,
        _ email: String,
        _ password: String
    ) -> AnyPublisher<AuthResult<LoginSuccessResponse, LoginErrorResponse>, Error>
    
    func register(
        _ clientId: String,
        _ email: String,
        _ password: String
    ) -> AnyPublisher<AuthResult<RegisterSuccessResponse, RegisterErrorResponse>, Error>
    
    func logout() -> AnyPublisher<AuthResult<LogoutSuccess, Empty>, Error>
    func getUserInfo() -> AnyPublisher<AuthResult<User, Empty>, Error>
}

class AuthService: AuthServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    func login(_ clientId: String, _ email: String, _ password: String) -> AnyPublisher<AuthResult<LoginSuccessResponse, LoginErrorResponse>, Error> {
        return networkManager.request(
            .login(
                clientId: clientId,
                email: email,
                password: password
            ),
            LoginSuccessResponse.self,
            LoginErrorResponse.self
        )
    }
    
    func register(_ clientId: String, _ email: String, _ password: String) -> AnyPublisher<AuthResult<RegisterSuccessResponse, RegisterErrorResponse>, Error> {
        return networkManager.request(
            .register(
                clientId: clientId,
                email: email,
                password: password
            ),
            RegisterSuccessResponse.self,
            RegisterErrorResponse.self
        )
    }
    
    func logout() -> AnyPublisher<AuthResult<LogoutSuccess, Empty>, Error> {
        return networkManager.request(.logout, LogoutSuccess.self, Empty.self)
    }
    
    func getUserInfo() -> AnyPublisher<AuthResult<User, Empty>, Error> {
        return networkManager.request(.getUserInfo, User.self, Empty.self)
    }
}
