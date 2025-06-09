//
//  NewsViewModel.swift
//  DemoNewsAutodoc
//
//  Created by DmitrySK on 21.05.2025.
//

import UIKit
import Combine

typealias Snapshot = NSDiffableDataSourceSnapshot<NewsCollectionSection, NewsViewItem>

protocol INewsRouter {
    func openDetails(for news: News)
}

enum NewsListState {
    case idle
    case initialLoading
    case loadingMore
    case loaded(snapshot: Snapshot)
    case error(String)
}

class NewsViewModel: INewsViewModel {
    
    @Published private var state: NewsListState = .idle
    // External predefined viewModel state
    var statePublisher: AnyPublisher<NewsListState, Never> {
        $state.eraseToAnyPublisher()
    }
    
    // Internal state
    private var allItems: [News] = []
    private var currentPage: Int = 1
    private var isLoading: Bool = false
    private var hasMoreToLoad: Bool = true
    private var searchQuery: String = ""
    private var isFiltering: Bool { !searchQuery.isEmpty }
    
    // Dependency
    private let repository: INewsRepository
    private let router: INewsRouter
    
    init(repository: INewsRepository, router: INewsRouter) {
        self.repository = repository
        self.router = router
    }
    
    func fetchNews() {
        if allItems.isEmpty {
            state = .initialLoading
        } else {
            state = .loadingMore
        }
        Task {
            do {
                let news = try await repository.fetchNews(page: currentPage)
                hasMoreToLoad = news.count > 0
                allItems.append(contentsOf: news)
                let snapshot = try createSnapshot(with: allItems)
                state = .loaded(snapshot: snapshot)
            } catch {
                print(error.localizedDescription)
                state = .error(error.localizedDescription)
            }
        }
    }
    
    private func createSnapshot(with news: [News]) throws -> Snapshot {
        guard news.count == Set(news).count else {
            throw NSError(domain: "DemoNewsAutodoc", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Items in snapshot will be not unique"])
        }
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        let items = news.map { NewsViewItem(id: $0.id, title: $0.title, imageUrl: $0.titleImageUrl) }
        snapshot.appendItems(items, toSection: .main)
        return snapshot
    }
    
    func didScrollToEnd() {
        guard !isLoading, hasMoreToLoad, !isFiltering else { return }
        currentPage += 1
        fetchNews()
    }
    
    func didTapOnCell(with id: Int) {
        guard let article = allItems.first(where: { $0.id == id }) else { return }
        router.openDetails(for: article)
    }
    
    func didSearchTextChanged(to query: String) {
        searchQuery = query
        let filtered: [News]
        if query.isEmpty {
            filtered = allItems
        } else {
            filtered = allItems.filter { $0.title.range(of: query, options: .caseInsensitive) != nil }
        }
        
        do {
            let snapshot = try createSnapshot(with: filtered)
            state = .loaded(snapshot: snapshot)
        } catch {
            print(error.localizedDescription)
            state = .error(error.localizedDescription)
        }
    }
    
    func reloadData() {
        currentPage = 1
        allItems = []
        hasMoreToLoad = true
        fetchNews()
    }
}
