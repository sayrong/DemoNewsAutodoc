//
//  Mocks.swift
//  DemoNewsAutodoc
//
//  Created by DmitrySK on 21.05.2025.
//

import UIKit
@testable import DemoNewsAutodoc


class MockNewsRepository: INewsRepository {
    var pageSize: Int = 1
    var fetchNewsCalled = false
    var newsToReturn: [News] = []
    var shouldThrowError = false

    func fetchNews(page: Int) async throws -> [News] {
        fetchNewsCalled = true
        if shouldThrowError {
            throw NSError(domain: "Test", code: 1, userInfo: nil)
        }
        return newsToReturn
    }
}


class MockNewsRouter: INewsRouter {
    var openDetailsCalledWith: News?
    func openDetails(for news: News) {
        openDetailsCalledWith = news
    }
}
