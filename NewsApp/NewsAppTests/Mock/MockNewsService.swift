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
    var categories: [String] = []
    var shouldFail: Bool = false
    
    func getArticle(_ limit: Int, _ offset: Int?, _ query: String, _ category: String) -> AnyPublisher<NewsApp.BaseResponse<[NewsApp.Article]>, Error> {
        if shouldFail {
            return Fail(error: NSError(domain: "", code: -1, userInfo: nil)).eraseToAnyPublisher()
        }
        
        return Just(BaseResponse.mockArticles)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getBlog(_ limit: Int, _ offset: Int?, _ query: String, _ category: String) -> AnyPublisher<NewsApp.BaseResponse<[NewsApp.Blog]>, Error> {
        return Fail(error: NSError(domain: "", code: -1, userInfo: nil)).eraseToAnyPublisher()
    }
    
    func getReport(_ limit: Int, _ offset: Int?, _ query: String, _ category: String) -> AnyPublisher<NewsApp.BaseResponse<[NewsApp.Report]>, Error> {
        return Fail(error: NSError(domain: "", code: -1, userInfo: nil)).eraseToAnyPublisher()
    }
    
    func getCategories() -> AnyPublisher<NewsApp.Category, Error> {
        return Fail(error: NSError(domain: "", code: -1, userInfo: nil)).eraseToAnyPublisher()
    }
}

extension BaseResponse where T == [Article] {
    static let mockArticles = BaseResponse(
        count: 100,
        next: nil,
        previous: nil,
        results: [
            Article.mock1
        ]
    )
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
        summary: "lorem ipsum dollar sit amet 2.",
        publishedAt: "",
        updatedAt: "",
        featured: false,
        launches: [],
        events: []
    )
}
