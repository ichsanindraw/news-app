//
//  NewsService.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 27/09/24.
//

import Combine

protocol NewsServiceProtocol {
    func getArticle(
        _ limit: Int,
        _ offset: Int?,
        _ query: String,
        _ category: String
    ) -> AnyPublisher<BaseResponse<[Article]>, Error>
    
    func getBlog(
        _ limit: Int,
        _ offset: Int?,
        _ query: String,
        _ category: String
    ) -> AnyPublisher<BaseResponse<[Blog]>, Error>
    
    func getReport(
        _ limit: Int,
        _ offset: Int?,
        _ query: String,
        _ category: String
    ) -> AnyPublisher<BaseResponse<[Report]>, Error>
    
    func getCategories() -> AnyPublisher<Category, Error>
    func logout(completion: (() -> Void)?)
}

class NewsService: NewsServiceProtocol {
    private let networkManager: NetworkManager
    private let userManager: UserManager

    init(
        networkManager: NetworkManager = NetworkManager(),
        userManager: UserManager = UserManager.shared
    ) {
        self.networkManager = networkManager
        self.userManager = userManager
    }
    
    func getArticle(_ limit: Int, _ offset: Int?, _ query: String, _ category: String) -> AnyPublisher<BaseResponse<[Article]>, Error> {
        return networkManager.request(.getArticles(
            limit: limit,
            offset: offset,
            query: query,
            category: category
        ), BaseResponse<[Article]>.self)
    }
    
    func getBlog(_ limit: Int, _ offset: Int?, _ query: String, _ category: String) -> AnyPublisher<BaseResponse<[Blog]>, Error> {
        return networkManager.request(.getBlogs(
            limit: limit,
            offset: offset,
            query: query,
            category: category
        ), BaseResponse<[Blog]>.self)
    }
    
    func getReport(_ limit: Int, _ offset: Int?, _ query: String, _ category: String) -> AnyPublisher<BaseResponse<[Report]>, Error> {
        return networkManager.request(.getReports(
            limit: limit,
            offset: offset,
            query: query,
            category: category
        ), BaseResponse<[Report]>.self)
    }
    
    func getCategories() -> AnyPublisher<Category, Error> {
        return networkManager.request(.getCategories, Category.self)
    }
    
    func logout(completion: (() -> Void)? = nil) {
        UserManager.shared.logout(shouldNotif: false, completion: { _ in
            completion?()
        })
    }
}
