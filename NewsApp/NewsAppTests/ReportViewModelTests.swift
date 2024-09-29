//
//  ReportViewModelTests.swift
//  NewsAppTests
//
//  Created by Ichsan Indra Wahyudi on 29/09/24.
//

import XCTest
import Combine

@testable import NewsApp

class ReportViewModelTests: XCTestCase {
    var viewModel: ReportViewModel!
    var mockService: MockNewsService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockService = MockNewsService()
        viewModel = ReportViewModel(newsService: mockService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertEqual(viewModel.reportsViewState, .loading)
        XCTAssertEqual(viewModel.categoryViewState, .loading)
        XCTAssertFalse(viewModel.isLoadMore)
        XCTAssertTrue(viewModel.recentSearch.isEmpty)
    }
    
    func testGetReportsSuccess() {
        let expectedReports: [Report] = [Report.mock1]
        let expectation = self.expectation(description: "Articles fetched successfully")
        
        mockService.reports = expectedReports
        viewModel.$reportsViewState
            .sink { state in
                if case let .success(articles) = state {
                    XCTAssertEqual(self.viewModel.totalResults, 100)
                    XCTAssertEqual(articles, expectedReports)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.getReports()
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testGetReportsFailure() {
        let expectation = self.expectation(description: "Articles fetched failure")
        
        mockService.shouldFail = true
        viewModel.$reportsViewState
            .sink { state in
                if case let .error(errorMessage) = state {
                    XCTAssertEqual(errorMessage, "server error")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.getReports()
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testSortArticles() {
        let expectedReports: [Report] = [Report.mock1, Report.mock2]
        let expectation = self.expectation(description: "Articles sorted successfully")
        var fulfillmentCalled = false
        
        mockService.reports = expectedReports
        viewModel.getReports()
        viewModel.sorted()
       
        viewModel.$reportsViewState
            .sink { state in
                if case let .success(articles) = state {
                    if !fulfillmentCalled {
                        fulfillmentCalled = true
                        XCTAssertEqual(articles, expectedReports)
                        expectation.fulfill()
                    }
                }
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testFilterByCategory() {
        let expectedReports: [Report] = [Report.mock1, Report.mock2]
        let expectation = self.expectation(description: "Successfully filter article by category")
        var fulfillmentCalled = false
        
        mockService.reports = expectedReports
        viewModel.getReports(category: "category 1")
        viewModel.filterBy(category: "category 1")
        
        viewModel.$reportsViewState
            .sink { state in
                if case let .success(articles) = state {
                    if !fulfillmentCalled {
                        fulfillmentCalled = true
                        XCTAssertEqual(articles, expectedReports)
                        expectation.fulfill()
                    }
                }
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testSearch() {
        let expectedReports: [Report] = [Report.mock1, Report.mock2]
        let expectation = self.expectation(description: "Successfully search article")
        
        mockService.reports = expectedReports
        viewModel.getReports()
        viewModel.search(query: "Team")
        
        viewModel.$reportsViewState
            .sink { state in
                if case let .success(articles) = state {
                    XCTAssertEqual(articles, expectedReports)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testLoadMoreArticles() {
        let expectedReports: [Report] = [Report.mock1, Report.mock2]
        let expectedReports2: [Report] = [Report.mock3, Report.mock4]
        let expectationResult = expectedReports + expectedReports2
        let expectation = self.expectation(description: "Successfully load more article")
        
        mockService.reports = expectedReports
        viewModel.getReports()
        mockService.reports = expectedReports2
        viewModel.loadMore()
        
        viewModel.$reportsViewState
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

