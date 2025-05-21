//
//  NewsViewModel.swift
//  DemoNewsAutodoc
//
//  Created by DmitrySK on 21.05.2025.
//

import UIKit

protocol INewsRouter {
    func openDetails(for news: News)
}

class NewsViewModel: INewsViewModel {
    
    private let repository: INewsRepository
    private let router: INewsRouter
    var snapshotDidChange: ((Snapshot) -> ())? = nil
    
    private var allItems: [News] = []
    private var currentPage: Int = 1
    private var isLoading: Bool = true
    private var hasMoreToLoad: Bool = true
    private var searchQuery: String = ""
    private var isFiltering: Bool { !searchQuery.isEmpty }
    
    
    init(repository: INewsRepository, router: INewsRouter, snapshotDidChange: ((Snapshot) -> Void)? = nil) {
        self.repository = repository
        self.router = router
        self.snapshotDidChange = snapshotDidChange
    }
    
    func fetchNews() {
        isLoading = true
        Task {
            defer {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
            do {
                let news = try await repository.fetchNews(page: currentPage)
                hasMoreToLoad = news.count > 0
                allItems.append(contentsOf: news)
                updateSnapshot(with: allItems)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateSnapshot(with news: [News]){
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        let items = news.map { NewsViewItem(id: $0.id, title: $0.title, imageUrl: $0.titleImageUrl) }
        snapshot.appendItems(items, toSection: .main)
        DispatchQueue.main.async {
            self.snapshotDidChange?(snapshot)
        }
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
        updateSnapshot(with: filtered)
    }
}
