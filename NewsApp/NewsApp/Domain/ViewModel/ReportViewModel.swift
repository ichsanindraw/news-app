//
//  ReportViewModel.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 28/09/24.
//

import Combine
import Foundation

class ReportViewModel {
    @Published var reportsViewState: ViewState<[Report]> = .loading
    @Published var categoryViewState: ViewState<[String]> = .loading
    @Published var isLoadMore: Bool = false
    @Published var recentSearch: [String] = []
    
    var currentPage = 1
    var totalResults = 0
    private var searchQuery = ""
    private var category = ""
    private var sortBy: SortBy = .asc
    private var cancellables = Set<AnyCancellable>()
    
    private let newsService: NewsServiceProtocol
    
    init(newsService: NewsServiceProtocol = NewsService()) {
        self.newsService = newsService
    }
    
    func sorted() {
        sortBy = sortBy == .asc ? .desc : .asc
        resetState()
        getReports(query: searchQuery, category: category, page: currentPage, sortBy: sortBy)
    }
    
    func filterBy(category: String) {
        resetState()
        getReports(query: searchQuery, category: category, page: currentPage, sortBy: sortBy)
    }
    
    func search(query: String) {
        resetState()
        searchQuery = query
        saveRecentSearch(query: query)
        getReports(query: query, category: category, page: currentPage, sortBy: sortBy)
    }

    private func resetState() {
        currentPage = 1
        totalResults = 0
        reportsViewState = .loading
    }
    
    func loadMore() {
        guard case let .success(data) = reportsViewState,
              !isLoadMore,
              data.count < totalResults
        else {
            return
        }
        
        currentPage += 1
        isLoadMore = true
        getReports(query: searchQuery, category: category, page: currentPage, sortBy: sortBy)
    }

    func getReports(query: String = "", category: String = "", page: Int = 1, sortBy: SortBy = .asc) {
        newsService.getReport(10, currentPage, searchQuery, category, sortBy)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoadMore = false
                
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.reportsViewState = .error(error.localizedDescription)
                }

            }, receiveValue: { [weak self] data in
                self?.totalResults = data.count
                   
                if case let .success(currentData) = self?.reportsViewState {
                    // When fetching subsequent pages, append the new data
                    self?.reportsViewState = .success(currentData + data.results)
                } else {
                    // When fetching the first page, replace the data
                    self?.reportsViewState = .success(data.results)
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


