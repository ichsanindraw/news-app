//
//  NewsViewModel.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 25/09/24.
//

import Combine
import UIKit

class NewsViewModel {
    @Published var articlesViewState: ViewState<[Article]> = .loading
    @Published var blogsViewState: ViewState<[Blog]> = .loading
    @Published var reportsViewState: ViewState<[Report]> = .loading
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""

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
        
        newsService.getArticle(limit, offset, query, category, .asc)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.articlesViewState = .error(error.localizedDescription)
                }

            }, receiveValue: { [weak self] data in
                self?.articlesViewState = .success(data.results)
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
        
        newsService.getBlog(limit, offset, query, category, .asc)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.blogsViewState = .error(error.localizedDescription)
                }

            }, receiveValue: { [weak self] data in
                self?.blogsViewState = .success(data.results)
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
        
        newsService.getReport(limit, offset, query, category, .asc)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.reportsViewState = .error(error.localizedDescription)
                }

            }, receiveValue: { [weak self] data in
                self?.reportsViewState = .success(data.results)
            })
            .store(in: &cancellables)
    }
    
    func logout() {
        isLoading = true
        
        print(">>> isLoading: \(isLoading)")
        
        newsService.logout(completion: { [weak self] in
            self?.isLoading = false
            print(">>> after isLoading: \(self?.isLoading)")
        })
    }
}
