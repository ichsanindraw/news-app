//
//  MockNewsService.swift
//  NewsAppTests
//
//  Created by Ichsan Indra Wahyudi on 28/09/24.
//

import Combine
import Foundation

@testable import NewsApp

class MockNewsService: NewsServiceProtocol {
    var articles: [Article] = []
    var blogs: [Blog] = []
    var reports: [Report] = []
    var categories: [String] = []
    var shouldFail: Bool = false
    
    func getArticle(_ limit: Int, _ offset: Int?, _ query: String, _ category: String, _ sortBy: NewsApp.SortBy) -> AnyPublisher<NewsApp.BaseResponse<[NewsApp.Article]>, Error> {
        if shouldFail {
            return Fail(error: NetworkError.serverError("server error")).eraseToAnyPublisher()
        }
        
        return Just(BaseResponse.mockArticles(articles))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getBlog(_ limit: Int, _ offset: Int?, _ query: String, _ category: String, _ sortBy: NewsApp.SortBy) -> AnyPublisher<NewsApp.BaseResponse<[NewsApp.Blog]>, Error> {
        if shouldFail {
            return Fail(error: NetworkError.serverError("server error")).eraseToAnyPublisher()
        }
        
        return Just(BaseResponse.mockBlogs(blogs))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getReport(_ limit: Int, _ offset: Int?, _ query: String, _ category: String, _ sortBy: NewsApp.SortBy) -> AnyPublisher<NewsApp.BaseResponse<[NewsApp.Report]>, Error> {
        if shouldFail {
            return Fail(error: NetworkError.serverError("server error")).eraseToAnyPublisher()
        }
        
        return Just(BaseResponse.mockReports(reports))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getCategories() -> AnyPublisher<NewsApp.Category, Error> {
        if shouldFail {
            return Fail(error: NetworkError.serverError("server error")).eraseToAnyPublisher()
        }
        
        return Just(Category.mock(categories))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func logout(completion: (() -> Void)?) {
        // Simulate an asynchronous logout operation
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            completion?()
        }
    }
}

extension BaseResponse where T == [Article] {
    static func mockArticles(_ articles: [Article]) -> Self {
        BaseResponse(
            count: 100,
            next: nil,
            previous: nil,
            results: articles
        )
    }
}

extension BaseResponse where T == [Blog] {
    static func mockBlogs(_ blogs: [Blog]) -> Self {
        BaseResponse(
            count: 100,
            next: nil,
            previous: nil,
            results: blogs
        )
    }
}

extension BaseResponse where T == [Report] {
    static func mockReports(_ reports: [Report]) -> Self {
        BaseResponse(
            count: 100,
            next: nil,
            previous: nil,
            results: reports
        )
    }
}

extension Article {
    static let mock1 = Article(
        id: 1,
        title: "title article 1",
        url: "",
        imageUrl: "",
        newsSite: "category 1",
        summary: "lorem ipsum dollar sit amet.",
        publishedAt: "",
        updatedAt: "",
        featured: false,
        launches: [],
        events: []
    )
    
    static let mock2 = Article(
        id: 2,
        title: "title article 2",
        url: "",
        imageUrl: "",
        newsSite: "category 2",
        summary: "lorem ipsum dollar sit amet.",
        publishedAt: "",
        updatedAt: "",
        featured: false,
        launches: [],
        events: []
    )
    
    static let mock3 = Article(
        id: 3,
        title: "title article 3",
        url: "",
        imageUrl: "",
        newsSite: "category 3",
        summary: "lorem ipsum dollar sit amet.",
        publishedAt: "",
        updatedAt: "",
        featured: false,
        launches: [],
        events: []
    )
    
    static let mock4 = Article(
        id: 4,
        title: "title article 4",
        url: "",
        imageUrl: "",
        newsSite: "category 4",
        summary: "lorem ipsum dollar sit amet.",
        publishedAt: "",
        updatedAt: "",
        featured: false,
        launches: [],
        events: []
    )
}


extension Blog {
    static let mock1 = Blog(
        id: 2,
        title: "title blog 2",
        url: "",
        imageUrl: "",
        newsSite: "category 2",
        summary: "lorem ipsum dollar sit amet.",
        publishedAt: "",
        updatedAt: "",
        featured: false,
        launches: [],
        events: []
    )
    
    static let mock2 = Blog(
        id: 2,
        title: "title blog 2",
        url: "",
        imageUrl: "",
        newsSite: "category 2",
        summary: "lorem ipsum dollar sit amet.",
        publishedAt: "",
        updatedAt: "",
        featured: false,
        launches: [],
        events: []
    )
    
    static let mock3 = Blog(
        id: 3,
        title: "title blog 3",
        url: "",
        imageUrl: "",
        newsSite: "category 3",
        summary: "lorem ipsum dollar sit amet.",
        publishedAt: "",
        updatedAt: "",
        featured: false,
        launches: [],
        events: []
    )
    
    static let mock4 = Blog(
        id: 4,
        title: "title blog 4",
        url: "",
        imageUrl: "",
        newsSite: "category 4",
        summary: "lorem ipsum dollar sit amet.",
        publishedAt: "",
        updatedAt: "",
        featured: false,
        launches: [],
        events: []
    )
}

extension Report {
    static let mock1 = Report(
        id: 2,
        title: "title blog 2",
        url: "",
        imageUrl: "",
        newsSite: "category 2",
        summary: "lorem ipsum dollar sit amet.",
        publishedAt: "",
        updatedAt: ""
    )
    
    static let mock2 = Report(
        id: 2,
        title: "title blog 2",
        url: "",
        imageUrl: "",
        newsSite: "category 2",
        summary: "lorem ipsum dollar sit amet.",
        publishedAt: "",
        updatedAt: ""
    )
    
    static let mock3 = Report(
        id: 3,
        title: "title blog 3",
        url: "",
        imageUrl: "",
        newsSite: "category 3",
        summary: "lorem ipsum dollar sit amet.",
        publishedAt: "",
        updatedAt: ""
    )
    
    static let mock4 = Report(
        id: 4,
        title: "title blog 4",
        url: "",
        imageUrl: "",
        newsSite: "category 4",
        summary: "lorem ipsum dollar sit amet.",
        publishedAt: "",
        updatedAt: ""
    )
}

extension NewsApp.Category {
    static func mock(_ categories: [String]) -> Self {
        Category(version: "", newsSites: categories)
    }
}
