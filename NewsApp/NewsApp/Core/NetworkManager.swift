//
//  NetworkManager.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 25/09/24.
//

import Foundation

import Combine
import Foundation

public class NetworkManager {
    func request<D: Decodable>(
        _ target: NewsTarget,
        _ responsetype: D.Type
    ) -> AnyPublisher<BaseResponse<D>, Error> {
        guard let urlRequest = createRequest(for: target) else {
            return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
        }
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
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
        guard var components = URLComponents(string: "https://api.spaceflightnewsapi.net/v4/\(target.path)") else {
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
}

enum NewsTarget {
    case article(limit: Int?)
    case blog(limit: Int?)
    case report(limit: Int?)
    
    var path: String {
        switch self {
        case .article:
            return "articles"
        case .blog:
            return "blogs"
        case .report:
            return "reports"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .article, .blog, .report:
            return .get
        }
    }
    
    var queryParameters: [String: Any]? {
        switch self {
        case let .article(limit):
            guard let limit else { return nil }
            
            return [
                "limit": limit
            ]
            
        case let .blog(limit):
            guard let limit else { return nil }
            
            return [
                "limit": limit
            ]
            
        case let .report(limit):
            guard let limit else { return nil }
            
            return [
                "limit": limit
            ]
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
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
