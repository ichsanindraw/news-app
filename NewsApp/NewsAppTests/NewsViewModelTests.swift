//
//  NewsViewModelTests.swift
//  NewsAppTests
//
//  Created by Ichsan Indra Wahyudi on 29/09/24.
//

import XCTest
import Combine
@testable import NewsApp

class NewsViewModelTests: XCTestCase {
    var viewModel: NewsViewModel!
    var mockService: MockNewsService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockService = MockNewsService()
        viewModel = NewsViewModel(newsService: mockService)
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
        XCTAssertEqual(viewModel.blogsViewState, .loading)
        XCTAssertEqual(viewModel.reportsViewState, .loading)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, "")
    }

    func testGetArticlesSuccess() {
        let expectedArticles: [Article] = [Article.mock1]
        let expectation = self.expectation(description: "Articles fetched successfully")
        
        mockService.articles = expectedArticles
        viewModel.$articlesViewState
            .sink { state in
                if case let .success(articles) = state {
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
    
    func testGetBlogsSuccess() {
        let expectedBlogs: [Blog] = [Blog.mock1]
        let expectation = self.expectation(description: "blogs fetched successfully")
        
        mockService.blogs = expectedBlogs
        viewModel.$blogsViewState
            .sink { state in
                if case let .success(blogs) = state {
                    XCTAssertEqual(blogs, expectedBlogs)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.getBlogs()
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testGetBlogsFailure() {
        let expectation = self.expectation(description: "blogs fetched failure")
        
        mockService.shouldFail = true
        viewModel.$blogsViewState
            .sink { state in
                if case let .error(errorMessage) = state {
                    XCTAssertEqual(errorMessage, "server error")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.getBlogs()
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testGetReportsSuccess() {
        let expectedReports: [Report] = [Report.mock1]
        let expectation = self.expectation(description: "Articles fetched successfully")
        
        mockService.reports = expectedReports
        viewModel.$reportsViewState
            .sink { state in
                if case let .success(articles) = state {
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

    func testLogout() {
        viewModel.logout()
        
        XCTAssertTrue(viewModel.isLoading)
        
        let expectation = expectation(description: "Wait for logout to complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertFalse(self.viewModel.isLoading)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }
}

