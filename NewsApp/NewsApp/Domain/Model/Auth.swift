//
//  Auth.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 28/09/24.
//

import Foundation

public enum AuthResult<S: Decodable, E: Decodable & Error>: Decodable {
    case success(S)
    case failure(E)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // Attempt to decode the success case first
        if let successData = try? container.decode(S.self) {
            self = .success(successData)
        } else {
            let errorData = try container.decode(E.self)
            self = .failure(errorData)
        }
    }
}

public struct Empty: Decodable & Error {}

public struct LogoutSuccess: Decodable {
    let status: String?
}

// MARK: Login

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

public struct RegisterSuccessResponse: Codable {
    let email: String
    let emailVerified: Bool
}

public struct RegisterErrorResponse: Codable, Error {
    let name: String
    let message: String?
}
