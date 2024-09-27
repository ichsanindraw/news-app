//
//  NewsTarget.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 26/09/24.
//

import Foundation

enum NewsTarget {
    case getArticles(limit: Int?, offset: Int?, query: String)
    case getBlogs(limit: Int?, offset: Int?, query: String)
    case getReports(limit: Int?, offset: Int?, query: String)
    
    var path: String {
        switch self {
        case .getArticles:
            return "articles"
        case .getBlogs:
            return "blogs"
        case .getReports:
            return "reports"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getArticles, .getBlogs, .getReports:
            return .get
        }
    }
    
    var queryParameters: [String: Any]? {
        switch self {
        case let .getArticles(limit, offset, query):
            var variables: [String: Any]?
            
            if let limit {
                variables = [
                    "limit": limit
                ]
            }
            
            if let offset {
                variables = [
                    "offset": offset
                ]
            }
            
            if !query.isEmpty {
                variables = [
                    "title_contains_all" : query
                ]
            }
            
            print(">>> variables: \(variables)")
            
            return variables
            
        case let .getBlogs(limit, offset, query):
            var variables: [String: Any]?
            
            if let limit {
                variables = [
                    "limit": limit
                ]
            }
            
            if let offset {
                variables = [
                    "offset": offset
                ]
            }
            
            if !query.isEmpty {
                variables = [
                    "title_contains_all" : query
                ]
            }
            
            return variables
            
        case let .getReports(limit, offset, query):
            var variables: [String: Any]?
            
            if let limit {
                variables = [
                    "limit": limit
                ]
            }
            
            if let offset {
                variables = [
                    "offset": offset
                ]
            }
            
            if !query.isEmpty {
                variables = [
                    "title_contains_all" : query
                ]
            }
            
            return variables
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

