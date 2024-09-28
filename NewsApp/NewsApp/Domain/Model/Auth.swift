//
//  Auth.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 28/09/24.
//

import Foundation

// MARK: Login

public enum LoginResult {
    case success(LoginSuccessResponse)
    case failure(LoginErrorResponse)
}

public struct LoginSuccessResponse: Codable {
    let accessToken: String
    let idToken: String
    let expiresIn: Int
}

public struct LoginErrorResponse: Codable, Error {
    let error: String
    let errorDescription: String
}

// MARK: Register

public enum RegisterResult {
    case success(RegisterSuccessResponse)
    case failure(RegisterErrorResponse)
}

public struct RegisterSuccessResponse: Codable {
    let email: String
    let emailVerified: Bool
}

public struct RegisterErrorResponse: Codable, Error {
    let name: String
    let message: String?
}
