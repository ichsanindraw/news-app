//
//  ArticleViewModel.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 27/09/24.
//

import Combine
import Foundation

class ArticleViewModel {
    @Published var articlesViewState: ViewState<[Article]> = .loading
    @Published var categoryViewState: ViewState<[String]> = .loading
    @Published var isLoadMore: Bool = false
    @Published var recentSearch: [String] = []
    
    private var currentPage = 1
    private var totalResults = 0
    private var searchQuery = ""
    private var category = ""
    private var cancellables = Set<AnyCancellable>()
    
    private let newsService: NewsServiceProtocol
    
    init(newsService: NewsServiceProtocol = NewsService()) {
        self.newsService = newsService
    }
    
    func filterBy(category: String) {
        resetState()
        getArticles(query: searchQuery, category: category, page: currentPage)
    }
    
    func searchArticles(query: String) {
        resetState()
        searchQuery = query
        saveRecentSearch(query: query)
        getArticles(query: query, category: category, page: currentPage)
    }

    private func resetState() {
        currentPage = 1
        totalResults = 0
        articlesViewState = .loading
    }
    
    func loadMoreArticles() {
        guard case let .success(data) = articlesViewState,
              !isLoadMore,
              data.count < totalResults
        else {
            return
        }
        
        currentPage += 1
        isLoadMore = true
        getArticles(query: searchQuery, category: category, page: currentPage)
    }

    func getArticles(query: String = "", category: String = "", page: Int = 1) {
        newsService.getArticle(10, currentPage, searchQuery, category)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoadMore = false
                
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.articlesViewState = .error(error.localizedDescription)
                }

            }, receiveValue: { [weak self] data in
                self?.totalResults = data.count
                   
                if case let .success(currentData) = self?.articlesViewState {
                    // When fetching subsequent pages, append the new data
                    self?.articlesViewState = .success(currentData + data.results)
                } else {
                    // When fetching the first page, replace the data
                    self?.articlesViewState = .success(data.results)
                }
            })
            .store(in: &cancellables)
    }
    
    func getCategories() {
        newsService.getCategories()
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoadMore = false
                
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.categoryViewState = .error(error.localizedDescription)
                }

            }, receiveValue: { [weak self] data in
                self?.categoryViewState = .success(data.newsSites)
            })
            .store(in: &cancellables)
    }
    
    func getRecentSearches() -> [String] {        
        recentSearch = UserDefaults.standard.stringArray(forKey: Constants.recentSearchKey) ?? []
        return recentSearch
    }
}
