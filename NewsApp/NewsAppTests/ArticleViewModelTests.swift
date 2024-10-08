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
    
    func testGetArticlesSuccess() {
        let expectedArticles: [Article] = [Article.mock1]
        let expectation = self.expectation(description: "Articles fetched successfully")
        
        mockService.articles = expectedArticles
        viewModel.$articlesViewState
            .sink { state in
                if case let .success(articles) = state {
                    XCTAssertEqual(self.viewModel.totalResults, 100)
                    XCTAssertEqual(articles, expectedArticles)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.getArticles()
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testGetArticlesFailure() {
        let expectation = self.expectation(description: "Articles fetched failure")
        
        mockService.shouldFail = true
        viewModel.$articlesViewState
            .sink { state in
                if case let .error(errorMessage) = state {
                    XCTAssertEqual(errorMessage, "server error")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.getArticles()
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testSortArticles() {
        let expectedArticles: [Article] = [Article.mock1, Article.mock2]
        let expectation = self.expectation(description: "Articles sorted successfully")
        var fulfillmentCalled = false
        
        mockService.articles = expectedArticles
        viewModel.getArticles()
        viewModel.sorted()
       
        viewModel.$articlesViewState
            .sink { state in
                if case let .success(articles) = state {
                    if !fulfillmentCalled {
                        fulfillmentCalled = true
                        XCTAssertEqual(articles, expectedArticles)
                        expectation.fulfill()
                    }
                }
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testFilterByCategory() {
        let expectedArticles: [Article] = [Article.mock1, Article.mock2]
        let expectation = self.expectation(description: "Successfully filter article by category")
        var fulfillmentCalled = false
        
        mockService.articles = expectedArticles
        viewModel.getArticles(category: "category 1")
        viewModel.filterBy(category: "category 1")
        
        viewModel.$articlesViewState
            .sink { state in
                if case let .success(articles) = state {
                    if !fulfillmentCalled {
                        fulfillmentCalled = true
                        XCTAssertEqual(articles, expectedArticles)
                        expectation.fulfill()
                    }
                }
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testSearch() {
        let expectedArticles: [Article] = [Article.mock1, Article.mock2]
        let expectation = self.expectation(description: "Successfully search article")
        
        mockService.articles = expectedArticles
        viewModel.getArticles()
        viewModel.search(query: "Team")
        
        viewModel.$articlesViewState
            .sink { state in
                if case let .success(articles) = state {
                    XCTAssertEqual(articles, expectedArticles)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testLoadMoreArticles() {
        let expectedArticles: [Article] = [Article.mock1, Article.mock2]
        let expectedArticles2: [Article] = [Article.mock3, Article.mock4]
        let expectationResult = expectedArticles + expectedArticles2
        let expectation = self.expectation(description: "Successfully load more article")
        
        mockService.articles = expectedArticles
        viewModel.getArticles()
        mockService.articles = expectedArticles2
        viewModel.loadMore()
        
        viewModel.$articlesViewState
            .sink { state in
                if case let .success(articles) = state {
                    XCTAssertEqual(articles, expectationResult)
                    XCTAssertEqual(self.viewModel.currentPage, 2)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testGetCategoriesSuccess() {
        let expectedCategory = ["Technology", "Sports"]
        let expectation = self.expectation(description: "Categories fetched successfully")
        
        mockService.categories = expectedCategory
        viewModel.$categoryViewState
            .dropFirst()
            .sink { state in
                if case let .success(categories) = state {
                    XCTAssertEqual(categories, expectedCategory)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.getCategories()
        
        waitForExpectations(timeout: 1.0)
    }

    func testGetCategoriesFailure() {
        let expectation = self.expectation(description: "Categories fetched failure")
        
        mockService.shouldFail = true
        viewModel.$categoryViewState
            .dropFirst()
            .sink { state in
                if case let .error(errorMessage) = state {
                    XCTAssertEqual(errorMessage, "server error")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.getCategories()
        
        waitForExpectations(timeout: 1.0)
    }
}
