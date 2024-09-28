//
//  NewsTarget.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 26/09/24.
//

import Foundation

enum NewsTarget {
    case getArticles(limit: Int?, offset: Int?, query: String, category: String)
    case getBlogs(limit: Int?, offset: Int?, query: String, category: String)
    case getReports(limit: Int?, offset: Int?, query: String, category: String)
    case getCategories
    
    var path: String {
        switch self {
        case .getArticles:
            return "articles"
        case .getBlogs:
            return "blogs"
        case .getReports:
            return "reports"
        case .getCategories:
            return "info"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getArticles, .getBlogs, .getReports, .getCategories:
            return .get
        }
    }
    
    var queryParameters: [String: Any]? {
        switch self {
        case let .getArticles(limit, offset, query, category):
            return getParams(
                limit: limit,
                offset: offset,
                query: query,
                category: category
            )
            
        case let .getBlogs(limit, offset, query, category):
            return getParams(
                limit: limit,
                offset: offset,
                query: query,
                category: category
            )
            
        case let .getReports(limit, offset, query, category):
            return getParams(
                limit: limit,
                offset: offset,
                query: query,
                category: category
            )
            
        case .getCategories:
            return nil
        }
    }
    
    func getParams(limit: Int?, offset: Int?, query: String, category: String) -> [String: Any]? {
        var variables: [String: Any]? = [:]
        
        if let limit {
            variables?["limit"] = limit
        }
        
        if let offset {
            variables?["offset"] = offset
        }
        
        if !query.isEmpty {
            variables?["title_contains_all"] = query
        }
        
        if !category.isEmpty {
            variables?["news_site"] = category
        }
        
        return variables
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

