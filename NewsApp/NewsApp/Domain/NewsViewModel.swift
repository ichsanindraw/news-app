//
//  NewsViewModel.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 25/09/24.
//

import Combine
import UIKit

class NewsViewModel {
    @Published var articlesViewState: ViewState<BaseResponse<[Article]>> = .loading
    @Published var blogsViewState: ViewState<BaseResponse<[Blog]>> = .loading
    @Published var reportsViewState: ViewState<BaseResponse<[Report]>> = .loading

    private let newsService: NewsServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(newsService: NewsServiceProtocol = NewsService()) {
        self.newsService = newsService
    }
    
    func getArticles(
        limit: Int = 10,
        offset: Int? = nil,
        query: String = ""
    ) {
        articlesViewState = .loading
        
        newsService.getArticle(limit, offset, query)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.articlesViewState = .error(error.localizedDescription)
                }

            }, receiveValue: { [weak self] data in
                self?.articlesViewState = .success(data)
            })
            .store(in: &cancellables)
    }
    
    func getBlogs(
        limit: Int = 10,
        offset: Int? = nil,
        query: String = ""
    ) {
        blogsViewState = .loading
        
        newsService.getBlog(limit, offset, query)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.blogsViewState = .error(error.localizedDescription)
                }

            }, receiveValue: { [weak self] data in
                self?.blogsViewState = .success(data)
            })
            .store(in: &cancellables)
    }
    
    func getReports(
        limit: Int = 10,
        offset: Int? = nil,
        query: String = ""
    ) {
        reportsViewState = .loading
        
        newsService.getReport(limit, offset, query)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.reportsViewState = .error(error.localizedDescription)
                }

            }, receiveValue: { [weak self] data in
                self?.reportsViewState = .success(data)
            })
            .store(in: &cancellables)
    }
}

protocol NewsServiceProtocol {
    func getArticle(
        _ limit: Int,
        _ offset: Int?,
        _ query: String
    ) -> AnyPublisher<BaseResponse<[Article]>, Error>
    
    func getBlog(
        _ limit: Int,
        _ offset: Int?,
        _ query: String
    ) -> AnyPublisher<BaseResponse<[Blog]>, Error>
    
    func getReport(
        _ limit: Int,
        _ offset: Int?,
        _ query: String
    ) -> AnyPublisher<BaseResponse<[Report]>, Error>
}

class NewsService: NewsServiceProtocol {
    private let networkManager = NetworkManager()
    private var cancellables = Set<AnyCancellable>()
    
    func getArticle(_ limit: Int, _ offset: Int?, _ query: String) -> AnyPublisher<BaseResponse<[Article]>, Error> {
        return networkManager.request(.getArticles(
            limit: limit,
            offset: offset,
            query: query
        ), [Article].self)
//        .receive(on: DispatchQueue.main)
//        .eraseToAnyPublisher()
    }
    
    func getBlog(_ limit: Int, _ offset: Int?, _ query: String) -> AnyPublisher<BaseResponse<[Blog]>, Error> {
        return networkManager.request(.getBlogs(
            limit: limit,
            offset: offset,
            query: query
        ), [Blog].self)
//        .receive(on: DispatchQueue.main)
//        .eraseToAnyPublisher()
    }
    
    func getReport(_ limit: Int, _ offset: Int?, _ query: String) -> AnyPublisher<BaseResponse<[Report]>, Error> {
        return networkManager.request(.getReports(
            limit: limit,
            offset: offset,
            query: query
        ), [Report].self)
//        .receive(on: DispatchQueue.main)
//        .eraseToAnyPublisher()
    }
}
