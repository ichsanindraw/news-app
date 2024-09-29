//
//  MockAuthService.swift
//  NewsAppTests
//
//  Created by Ichsan Indra Wahyudi on 29/09/24.
//

import Combine
import Foundation

@testable import NewsApp

class MockAuthService: AuthServiceProtocol {
    var shouldSucceed: Bool = true
    var shouldFail: Bool = false
    var error: Error?
    
    
    func login(_ clientId: String, _ email: String, _ password: String) -> AnyPublisher<AuthResult<LoginSuccessResponse, LoginErrorResponse>, Error> {
        if shouldFail {
            return Fail(error: NetworkError.serverError("server error")).eraseToAnyPublisher()
        }
        
        return Just(AuthResult.success(LoginSuccessResponse.mock))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func register(_ clientId: String, _ email: String, _ password: String) -> AnyPublisher<AuthResult<RegisterSuccessResponse, RegisterErrorResponse>, Error> {
        if shouldFail {
            return Fail(error: NetworkError.serverError("server error")).eraseToAnyPublisher()
        }
        
        return Just(AuthResult.success(RegisterSuccessResponse.mock))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<AuthResult<LogoutSuccess, NewsApp.Empty>, Error> {
        if shouldFail {
            return Fail(error: NetworkError.serverError("server error")).eraseToAnyPublisher()
        }
        
        return Just(AuthResult.success(LogoutSuccess.mock))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getUserInfo() -> AnyPublisher<AuthResult<User, NewsApp.Empty>, Error> {
        if shouldFail {
            return Fail(error: NetworkError.serverError("server error")).eraseToAnyPublisher()
        }
        
        return Just(AuthResult.success(User.mock))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

extension LoginSuccessResponse {
    static let mock = LoginSuccessResponse(accessToken: "accessToken", idToken: "idToken", expiresIn: 1)
}

extension RegisterSuccessResponse {
    static let mock = RegisterSuccessResponse(email: "ichsan@gmail.com", emailVerified: true)
}

extension LogoutSuccess {
    static let mock = LogoutSuccess(status: "Ok")
}

extension User {
    static let mock = User(name: "ichsanindraw", nickname: "ichsan", email: "ichsan@gmail.com")
}
