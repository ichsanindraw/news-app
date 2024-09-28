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
        query: String = "",
        category: String = ""
    ) {
        articlesViewState = .loading
        
        newsService.getArticle(limit, offset, query, category)
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
        query: String = "",
        category: String = ""
    ) {
        blogsViewState = .loading
        
        newsService.getBlog(limit, offset, query, category)
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
        query: String = "",
        category: String = ""
    ) {
        reportsViewState = .loading
        
        newsService.getReport(limit, offset, query, category)
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
