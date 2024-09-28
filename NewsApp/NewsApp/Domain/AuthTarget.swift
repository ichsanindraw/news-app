//
//  AuthTarget.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 28/09/24.
//

import Foundation

public enum AuthTarget {
    case login(clientId: String, email: String, password: String)
    case register(clientId: String, email: String, password: String)
    case logout
    case getUserInfo
    
    var baseUrl: String {
        return "https://\(getAuth0Configuration().domain)" 
    }
    
    var path: String {
        switch self {
        case .login:
            return "oauth/token"
        case .register:
            return "dbconnections/signup"
        case .logout:
            return "v2/logout"
        case .getUserInfo:
            return "userinfo"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .register:
            return .post
            
        case .logout, .getUserInfo:
            return .get
        }
    }
    
    var queryParameters: [String: Any]? {
        switch self {
        case let .login(clientId, email, password):
            return [
                "client_id": clientId,
                "email": email,
                "password": password,
                "username": email,
                "grant_type": "password",
                "connection": "Username-Password-Authentication"
            ]
            
        case let .register(clientId, email, password):
            return [
                "client_id": clientId,
                "email": email,
                "password": password,
                "connection": "Username-Password-Authentication"
            ]
            
        case .logout, .getUserInfo:
            return nil
        }
    }
    
    var headers: [String : String]? {
        [:]
    }
}
