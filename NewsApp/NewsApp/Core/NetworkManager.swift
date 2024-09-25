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
        _ target: Target,
        _ responsetype: D.Type
    ) -> AnyPublisher<BaseResponse<D>, Error> {
        guard let url = URL(string: "https://api.spaceflightnewsapi.net/v4/\(target.path)") else {
            return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
        }
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return URLSession.shared.dataTaskPublisher(for: url)
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
}

enum Target {
    case article
    case blog
    case report
    
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
