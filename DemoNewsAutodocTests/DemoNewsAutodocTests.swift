//
//  DemoNewsAutodocTests.swift
//  DemoNewsAutodocTests
//
//  Created by DmitrySK on 20.05.2025.
//

import XCTest
@testable import DemoNewsAutodoc

final class DemoNewsAutodocTests: XCTestCase {

    var mockRepo: MockNewsRepository!
    var mockRouter: MockNewsRouter!
    
    override func setUp() {
        mockRepo = MockNewsRepository()
        mockRouter = MockNewsRouter()
    }

    func testFetchNews_success_updatesSnapshot() {
        // Given
        let item = News(id: 1, title: "Title", description: "Desc", publishedDate: Date(),
                        titleImageUrl: URL(string: "http://example.com")!,
                        fullUrl: URL(string: "http://example.com")!, categoryType: "Cat")
        mockRepo.newsToReturn = [item]
        let viewModel = NewsViewModel(repository: mockRepo, router: mockRouter)
        let expectation = expectation(description: "Snapshot updated")
        viewModel.snapshotDidChange = { snapshot in
            expectation.fulfill()
        }
        // When
        viewModel.fetchNews()
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(mockRepo.fetchNewsCalled)
    }

    func testFilterNews_withQuery_filtersCorrectly() {
        // Given
        let news1 = News(id: 1, title: "Apple", description: "", publishedDate: Date(), titleImageUrl: URL(string: "http://a.com")!, fullUrl: URL(string: "http://a.com")!, categoryType: "")
        let news2 = News(id: 2, title: "Banana", description: "", publishedDate: Date(), titleImageUrl: URL(string: "http://b.com")!, fullUrl: URL(string: "http://b.com")!, categoryType: "")
        mockRepo.newsToReturn = [news1, news2]
        let viewModel = NewsViewModel(repository: mockRepo, router: mockRouter)
        let loadExpectation = expectation(description: "Data loaded")
        // Load data
        viewModel.fetchNews()
        viewModel.snapshotDidChange = { _ in
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1.0)
        // Check configure
        var snapshotItems: [NewsViewItem] = []
        let filterExpectation = expectation(description: "Data filtered")
        viewModel.snapshotDidChange = { snapshot in
            snapshotItems = snapshot.itemIdentifiers
            filterExpectation.fulfill()
        }
        // When
        viewModel.didSearchTextChanged(to: "Banana")
        // Then
        wait(for: [filterExpectation], timeout: 1.0)
        XCTAssertEqual(snapshotItems.count, 1)
        XCTAssertEqual(snapshotItems.first?.title, "Banana")
    }

    func testDidScrollToEnd_fetchesNextPage_whenNotFiltering() {
        // Given
        let news = News(id: 1, title: "Test", description: "", publishedDate: Date(), titleImageUrl: URL(string: "http://a.com")!, fullUrl: URL(string: "http://a.com")!, categoryType: "")
        mockRepo.newsToReturn = [news]
        let viewModel = NewsViewModel(repository: mockRepo, router: mockRouter)
        let expectation = expectation(description: "FetchesNextPage")
        viewModel.snapshotDidChange = { _ in 
            expectation.fulfill()
        }
        // When
        viewModel.didScrollToEnd()
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(mockRepo.fetchNewsCalled)
    }

    func testDidScrollToEnd_doesNotPaginate_whenFiltering() {
        // Given
        let viewModel = NewsViewModel(repository: mockRepo, router: mockRouter)
        let expectation = expectation(description: "DoesNotPaginate")
        viewModel.snapshotDidChange = { _ in 
            expectation.fulfill()
        }
        viewModel.didSearchTextChanged(to: "query")
        // When
        viewModel.didScrollToEnd()
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(mockRepo.fetchNewsCalled)
    }
}
