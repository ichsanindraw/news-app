//
//  ArticleViewModelTests.swift
//  NewsAppTests
//
//  Created by Ichsan Indra Wahyudi on 28/09/24.
//

import XCTest
import Combine

@testable import NewsApp

class ArticleViewModelTests: XCTestCase {
    var viewModel: ArticleViewModel!
    var mockService: MockNewsService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockService = MockNewsService()
        viewModel = ArticleViewModel(newsService: mockService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertEqual(viewModel.articlesViewState, .loading)
        XCTAssertEqual(viewModel.categoryViewState, .loading)
        XCTAssertFalse(viewModel.isLoadMore)
        XCTAssertTrue(viewModel.recentSearch.isEmpty)
    }

    func testSearchArticlesUpdatesViewState() {
        let expectation = self.expectation(description: "Articles loaded")
//        var isFulfilled = false
        
        mockService.articles = [
            Article.mock1
        ]

        viewModel.$articlesViewState
            .dropFirst() // Skip the initial loading state
            .sink { state in
                if case let .success(articles) = state {
                    // Only assert and fulfill if it hasn't been done yet
//                    if !isFulfilled {
                        XCTAssertEqual(articles.count, 1)
                        XCTAssertEqual(articles.first?.title, "title article 1")
                        expectation.fulfill()
//                        isFulfilled = true // Set flag to true
//                    }
                }
            }
            .store(in: &cancellables)

        viewModel.searchArticles(query: "Test")
        waitForExpectations(timeout: 1.0)
    }
    
//    func testLoadMoreArticles_Success() {
//        // Arrange
//        let mockService = MockNewsService()
//        mockService.results = ArticleResponse(results: [/* Your mock articles */], totalResults: 20)
////        viewModel.newsService = mockService // Assign your mock service
//        viewModel.articlesViewState = .success([/* Existing articles */]) // Existing articles in the view state
//        viewModel.currentPage = 1 // Set current page
//        viewModel.totalResults = 20 // Set total results
//        viewModel.isLoadMore = false // Reset load more flag
//
//        // Act
//        viewModel.loadMoreArticles()
//
//        // Assert
//        XCTAssertEqual(viewModel.currentPage, 2)
//        XCTAssertTrue(viewModel.isLoadMore)
//    }

    func testLoadMoreArticles() {
        let expectation = self.expectation(description: "More articles loaded")
        mockService.articles = [
            Article.mock1
        ]
        viewModel.searchArticles(query: "Test")

        viewModel.$articlesViewState
            .dropFirst() // Skip the first loading and success state
            .sink { state in
                if case .success(let articles) = state {
                    print(">>> articles: \(articles.count)")
                    XCTAssertEqual(articles.count, 2) // Assuming we load more articles here
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.loadMoreArticles()
        waitForExpectations(timeout: 1.0)
    }

    func testGetCategoriesUpdatesViewState() {
        let expectation = self.expectation(description: "Categories loaded")
        mockService.categories = ["Category 1", "Category 2"]

        viewModel.$categoryViewState
            .dropFirst() // Skip the initial loading state
            .sink { state in
                if case .success(let categories) = state {
                    XCTAssertEqual(categories.count, 2)
                    XCTAssertEqual(categories.first, "Category 1")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.getCategories()
        waitForExpectations(timeout: 1.0)
    }

    func testSearchArticlesSavesRecentSearch() {
        viewModel.searchArticles(query: "Test")
        let recentSearches = viewModel.getRecentSearches()
        XCTAssertEqual(recentSearches.first, "Test")
    }

    func testErrorHandlingInGetArticles() {
        mockService.shouldFail = true
        let expectation = self.expectation(description: "Error state updated")

        viewModel.$articlesViewState
            .dropFirst() // Skip initial loading state
            .sink { state in
                if case .error(let errorMessage) = state {
                    XCTAssertNotNil(errorMessage)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.getArticles()
        waitForExpectations(timeout: 1.0)
    }

    func testErrorHandlingInGetCategories() {
        mockService.shouldFail = true
        let expectation = self.expectation(description: "Category error state updated")

        viewModel.$categoryViewState
            .dropFirst() // Skip initial loading state
            .sink { state in
                if case .error(let errorMessage) = state {
                    XCTAssertNotNil(errorMessage)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.getCategories()
        waitForExpectations(timeout: 1.0)
    }
}
