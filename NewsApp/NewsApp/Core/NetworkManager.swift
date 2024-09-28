//
//  NetworkManager.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 25/09/24.
//

import Foundation

import Combine
import Foundation

public class NetworkManager: NSObject, URLSessionDelegate {
    private var session: URLSession!
        
    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    func request<D: Decodable>(
        _ target: NewsTarget,
        _ responsetype: D.Type
    ) -> AnyPublisher<D, Error> {
        guard let urlRequest = createRequest(for: target) else {
            return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
        }
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { result -> Data in
                guard let response = result.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw NetworkError.serverError("Server responded with error.")
                }
                
                return result.data
            }
            .decode(type: D.self, decoder: jsonDecoder)
            .mapError { error -> NetworkError in
                if let urlError = error as? URLError {
                    return .serverError(urlError.localizedDescription)
                } else if let decodingError = error as? DecodingError {
                    return .serverError("Decoding error: \(decodingError.localizedDescription)")
                } else {
                    return .invalidResponse
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func createRequest(for target: NewsTarget) -> URLRequest? {
        guard var components = URLComponents(string: "\(Constants.API_URL)/\(target.path)") else {
            return nil
        }
        
        components.queryItems = target.queryParameters?.map { key, value in
            URLQueryItem(name: key, value: "\(value)")
        }
        
        guard let url = components.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = target.method.rawValue
        
        return request
    }
    
    // MARK: - URLSessionDelegate for SSL Pinning
        
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // Fetch the certificate chain from the server
        var certificates: [SecCertificate] = []
       
        if #available(iOS 15.0, *) {
           if let certificateChain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate] {
               certificates = certificateChain
           }
        } else {
            if let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                certificates = [certificate]
            }
        }
        
        guard let serverCertificate = certificates.first else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // Load your local certificate
        if let localCertificatePath = Bundle.main.path(forResource: "spaceflightnewsapi.net", ofType: "cer"),
           let localCertificateData = NSData(contentsOfFile: localCertificatePath),
           let serverCertificateData = SecCertificateCopyData(serverCertificate) as Data? {
            
            // Compare the certificates
            if localCertificateData.isEqual(to: serverCertificateData) {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
            } else {
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
    
    // MARK: For Authentication
    
    public func request<S: Decodable, E: Decodable>(
        _ target: AuthTarget,
        _ responseType: S.Type,
        _ errorType: E.Type
    ) -> AnyPublisher<AuthResult<S, E>, Error> {
        guard let urlRequest = createRequest(for: target) else {
            return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
        }
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                // Print the raw response as a string (for debugging purposes)
                let jsonString = String(data: data, encoding: .utf8)
                print("Raw response: \(jsonString ?? "No Data")")
                
                if (200...299).contains(httpResponse.statusCode) {
                    return data
                } else {
                    throw try jsonDecoder.decode(E.self, from: data)
                }
            }
            .decode(type: S.self, decoder: jsonDecoder)
            .map { .success($0) }
            .catch { error -> AnyPublisher<AuthResult, Error> in
                guard  let errorResponse = error as? E else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                
                return Just(.failure(errorResponse))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func createRequest(for target: AuthTarget) -> URLRequest? {
        guard var components = URLComponents(string: "\(target.baseUrl)/\(target.path)") else {
            return nil
        }
        
        components.queryItems = target.queryParameters?.map { key, value in
            URLQueryItem(name: key, value: "\(value)")
        }
        
        guard let url = components.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = target.method.rawValue
        request.allHTTPHeaderFields = target.headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let accessToken = KeychainManager.shared.getAccessToken() {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    public func signup(email: String, password: String) -> AnyPublisher<RegisterResult, Error> {
        let auth0Config = getAuth0Configuration()
        
        guard let clientId = auth0Config.clientId,
              let domain = auth0Config.domain,
              let url = URL(string: "https://\(domain)/dbconnections/signup") else {
            return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "client_id": clientId,
            "email": email,
            "password": password,
            "connection": "Username-Password-Authentication"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                // Print the raw response as a string (for debugging purposes)
                let jsonString = String(data: data, encoding: .utf8)
                print("Raw response: \(jsonString ?? "No Data")")
                
                if (200...299).contains(httpResponse.statusCode) {
                    return data
                } else {
                    throw try jsonDecoder.decode(RegisterErrorResponse.self, from: data)
                }
            }
            .decode(type: RegisterSuccessResponse.self, decoder: jsonDecoder)
            .map { .success($0) }
            .catch { error -> AnyPublisher<RegisterResult, Error> in
                guard  let errorResponse = error as? RegisterErrorResponse else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                
                return Just(.failure(errorResponse))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    public func signIn(email: String, password: String) -> AnyPublisher<LoginResult, Error> {
        let auth0Config = getAuth0Configuration()
        
        guard let clientId = auth0Config.clientId,
              let domain = auth0Config.domain,
              let url = URL(string: "https://\(domain)/oauth/token") else {
            return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "client_id": clientId,
            "email": email,
            "password": password,
            "username": email,
            "grant_type": "password",
            "connection": "Username-Password-Authentication"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                let jsonString = String(data: data, encoding: .utf8)
                print("Raw response: \(jsonString ?? "No Data")")

                if (200...299).contains(httpResponse.statusCode) {
                   return data
                } else {
                    throw try jsonDecoder.decode(LoginErrorResponse.self, from: data)
                }
            }
            .decode(type: LoginSuccessResponse.self, decoder: jsonDecoder)
            .map { .success($0) }
            .catch { error -> AnyPublisher<LoginResult, Error> in
                guard  let errorResponse = error as? LoginErrorResponse else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                
                return Just(.failure(errorResponse))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    public func logout() -> AnyPublisher<Void, Error>  {
        let auth0Config = getAuth0Configuration()
        
        guard let domain = auth0Config.domain,
              let url = URL(string: "https://\(domain)/v2/logout") else {
            return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Void in
                guard response is HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                return
            }
            .eraseToAnyPublisher()
    }
    
    public func userInfo() -> AnyPublisher<User, Error> {
        let auth0Config = getAuth0Configuration()
        
        guard let domain = auth0Config.domain,
              let url = URL(string: "https://\(domain)/userinfo"),
              let accessToken = KeychainManager.shared.getAccessToken() else {
            return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Data in
                guard response is HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                let jsonString = String(data: data, encoding: .utf8)
                print("Raw response: \(jsonString ?? "No Data")")

                return data
            }
            .decode(type: User.self, decoder: jsonDecoder)
            .map { $0 }
            .catch { error -> AnyPublisher<User, Error> in
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

enum NetworkError: LocalizedError {
    case invalidResponse
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from the server."
        case let .serverError(message):
            return message
        }
    }
}
