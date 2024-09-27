//
//  ArticleViewModel.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 27/09/24.
//

import Combine
import Foundation

class ArticleViewModel {
    @Published var viewState: ViewState<[Article]> = .loading
    @Published var isLoadMore: Bool = false
    
    private var currentPage = 1
    private var totalResults = 0
    private var searchQuery = ""
    private var cancellables = Set<AnyCancellable>()
    
    private let newsService: NewsServiceProtocol
    
    init(newsService: NewsServiceProtocol = NewsService()) {
        self.newsService = newsService
    }
    
    func searchArticles(query: String) {
        resetPagination()
        searchQuery = query
        viewState = .success([])
        getArticles(query: query, page: currentPage)
    }
    
    func loadMoreArticles() {
        guard case let .success(data) = viewState,
              !isLoadMore,
              data.count < totalResults
        else {
            return
        }
        
        print(">>> loadMoreArticles -> \(isLoadMore)")
        
        currentPage += 1
        isLoadMore = true
        getArticles(query: searchQuery, page: currentPage)
    }

    
    func getArticles(query: String = "", page: Int = 1) {
        newsService.getArticle(10, currentPage, searchQuery)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoadMore = false
                
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.viewState = .error(error.localizedDescription)
                }

            }, receiveValue: { [weak self] data in
                self?.totalResults = data.count
                   
                if case let .success(currentData) = self?.viewState {
                    // When fetching subsequent pages, append the new data
                    self?.viewState = .success(currentData + data.results)
                } else {
                    // When fetching the first page, replace the data
                    self?.viewState = .success(data.results)
                }
            })
            .store(in: &cancellables)
    }
    
    private func resetPagination() {
        currentPage = 1
        totalResults = 0
    }
}
