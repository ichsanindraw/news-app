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
    ) -> AnyPublisher<BaseResponse<D>, Error> {
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
            .decode(type: BaseResponse<D>.self, decoder: jsonDecoder)
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
