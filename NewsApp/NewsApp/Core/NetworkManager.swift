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
                guard let response = result.response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
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
                
                if (200...299).contains(httpResponse.statusCode) {
                    let jsonString = String(data: data, encoding: .utf8)
                    
                    guard jsonString?.lowercased() == "ok" else {
                        return data
                    }
                    
                    return """
                        {
                            "status": "OK"
                        }
                    """.data(using: .utf8)!
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
        
        if case .get = target.method {
            components.queryItems = target.queryParameters?.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }
        
        guard let url = components.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = target.method.rawValue
        request.allHTTPHeaderFields = target.headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if case .post = target.method {
            request.httpBody = try? JSONSerialization.data(withJSONObject: target.queryParameters ?? [])
        }
        
        if let accessToken = KeychainManager.shared.getAccessToken() {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        return request
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
