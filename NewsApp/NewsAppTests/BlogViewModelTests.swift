//
//  BlogViewModelTests.swift
//  NewsAppTests
//
//  Created by Ichsan Indra Wahyudi on 29/09/24.
//

import XCTest
import Combine

@testable import NewsApp

class BlogViewModelTests: XCTestCase {
    var viewModel: BlogViewModel!
    var mockService: MockNewsService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockService = MockNewsService()
        viewModel = BlogViewModel(newsService: mockService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertEqual(viewModel.blogsViewState, .loading)
        XCTAssertEqual(viewModel.categoryViewState, .loading)
        XCTAssertFalse(viewModel.isLoadMore)
        XCTAssertTrue(viewModel.recentSearch.isEmpty)
    }
    
    func testGetBlogsSuccess() {
        let expectedBlogs: [Blog] = [Blog.mock1]
        let expectation = self.expectation(description: "blogs fetched successfully")
        
        mockService.blogs = expectedBlogs
        viewModel.$blogsViewState
            .sink { state in
                if case let .success(blogs) = state {
                    XCTAssertEqual(self.viewModel.totalResults, 100)
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
    
    func testSortblogs() {
        let expectedBlogs: [Blog] = [Blog.mock1, Blog.mock2]
        let expectation = self.expectation(description: "blogs sorted successfully")
        var fulfillmentCalled = false
        
        mockService.blogs = expectedBlogs
        viewModel.getBlogs()
        viewModel.sorted()
       
        viewModel.$blogsViewState
            .sink { state in
                if case let .success(blogs) = state {
                    if !fulfillmentCalled {
                        fulfillmentCalled = true
                        XCTAssertEqual(blogs, expectedBlogs)
                        expectation.fulfill()
                    }
                }
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testFilterByCategory() {
        let expectedBlogs: [Blog] = [Blog.mock1, Blog.mock2]
        let expectation = self.expectation(description: "Successfully filter article by category")
        var fulfillmentCalled = false
        
        mockService.blogs = expectedBlogs
        viewModel.getBlogs(category: "category 1")
        viewModel.filterBy(category: "category 1")
        
        viewModel.$blogsViewState
            .sink { state in
                if case let .success(blogs) = state {
                    if !fulfillmentCalled {
                        fulfillmentCalled = true
                        XCTAssertEqual(blogs, expectedBlogs)
                        expectation.fulfill()
                    }
                }
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testSearch() {
        let expectedBlogs: [Blog] = [Blog.mock1, Blog.mock2]
        let expectation = self.expectation(description: "Successfully search article")
        
        mockService.blogs = expectedBlogs
        viewModel.getBlogs()
        viewModel.search(query: "Team")
        
        viewModel.$blogsViewState
            .sink { state in
                if case let .success(blogs) = state {
                    XCTAssertEqual(blogs, expectedBlogs)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testLoadMoreblogs() {
        let expectedBlogs: [Blog] = [Blog.mock1, Blog.mock2]
        let expectedBlogs2: [Blog] = [Blog.mock3, Blog.mock4]
        let expectationResult = expectedBlogs + expectedBlogs2
        let expectation = self.expectation(description: "Successfully load more article")
        
        mockService.blogs = expectedBlogs
        viewModel.getBlogs()
        mockService.blogs = expectedBlogs2
        viewModel.loadMore()
        
        viewModel.$blogsViewState
            .sink { state in
                if case let .success(blogs) = state {
                    XCTAssertEqual(blogs, expectationResult)
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
