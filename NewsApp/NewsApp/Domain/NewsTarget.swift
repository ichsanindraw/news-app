//
//  NewsTarget.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 26/09/24.
//

import Foundation

enum NewsTarget {
    case getArticles(limit: Int?, offset: Int?, query: String, category: String, sortBy: SortBy)
    case getBlogs(limit: Int?, offset: Int?, query: String, category: String, sortBy: SortBy)
    case getReports(limit: Int?, offset: Int?, query: String, category: String, sortBy: SortBy)
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
        case let .getArticles(limit, offset, query, category, sortBy):
            return getParams(
                limit: limit,
                offset: offset,
                query: query,
                category: category,
                sortBy: sortBy
            )
            
        case let .getBlogs(limit, offset, query, category, sortBy):
            return getParams(
                limit: limit,
                offset: offset,
                query: query,
                category: category,
                sortBy: sortBy
            )
            
        case let .getReports(limit, offset, query, category, sortBy):
            return getParams(
                limit: limit,
                offset: offset,
                query: query,
                category: category,
                sortBy: sortBy
            )
            
        case .getCategories:
            return nil
        }
    }
    
    func getParams(limit: Int?, offset: Int?, query: String, category: String, sortBy: SortBy) -> [String: Any]? {
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
        
        let order: String
        
        switch sortBy {
        case .asc:
            order = "published"
        case .desc:
            order = "-published"
        }
        
        variables?["ordering"] = order
        
        return variables
    }
}
