//
//  LoginViewModelTests.swift
//  NewsAppTests
//
//  Created by Ichsan Indra Wahyudi on 29/09/24.
//

import Combine
import XCTest

@testable import NewsApp

class LoginViewModelTests: XCTestCase {
    var viewModel: LoginViewModel!
    var mockAuthService: MockAuthService!

    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        viewModel = LoginViewModel(authService: mockAuthService)
    }

    override func tearDown() {
        viewModel = nil
        mockAuthService = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(viewModel.email, "")
        XCTAssertEqual(viewModel.password, "")
        XCTAssertFalse(viewModel.isEmailValid)
        XCTAssertFalse(viewModel.isButtonEnabled)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.isLoggedIn)
        XCTAssertEqual(viewModel.errorMessage, nil)
    }

    func testEmailValidation() {
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        
        XCTAssertTrue(viewModel.isEmailValid)
        XCTAssertTrue(viewModel.isButtonEnabled)
    }

    func testLoginSuccess() {
        let expectation = self.expectation(description: "Login should succeed")

        let cancellable = viewModel.$isLoggedIn
            .sink { isLoggedIn in
                if isLoggedIn {
                    expectation.fulfill()
                }
            }

        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        viewModel.login()

        waitForExpectations(timeout: 1) { _ in
            cancellable.cancel()
            XCTAssertTrue(self.viewModel.isLoggedIn)
        }
    }

    func testLoginFailure() {
        mockAuthService.shouldFail = true
        mockAuthService.error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Login failed"])

        let expectation = self.expectation(description: "Login should fail")

        // Listen for changes in errorMessage
        let cancellable = viewModel.$errorMessage.sink { errorMessage in
            if errorMessage != nil {
                expectation.fulfill()
            }
        }

        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        viewModel.login()

        waitForExpectations(timeout: 1) { _ in
            cancellable.cancel()
            XCTAssertEqual(self.viewModel.errorMessage, "server error")
        }
    }

    func testRegisterSuccess() {
        mockAuthService.shouldFail = false

        let expectation = self.expectation(description: "Register should succeed")

        // Listen for changes in isLoggedIn
        let cancellable = viewModel.$isLoggedIn.sink { isLoggedIn in
            if isLoggedIn {
                expectation.fulfill()
            }
        }

        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        viewModel.register()

        waitForExpectations(timeout: 1) { _ in
            cancellable.cancel()
            XCTAssertTrue(self.viewModel.isLoggedIn)
        }
    }

    func testRegisterFailure() {
        mockAuthService.shouldFail = true
        mockAuthService.error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Registration failed"])

        let expectation = self.expectation(description: "Register should fail")

        // Listen for changes in errorMessage
        let cancellable = viewModel.$errorMessage.sink { errorMessage in
            if errorMessage != nil {
                expectation.fulfill()
            }
        }

        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        viewModel.register()

        waitForExpectations(timeout: 1) { _ in
            cancellable.cancel()
            XCTAssertEqual(self.viewModel.errorMessage, "server error")
        }
    }
}

