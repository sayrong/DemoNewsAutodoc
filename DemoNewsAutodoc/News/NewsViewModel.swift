//
//  NewsViewModel.swift
//  DemoNewsAutodoc
//
//  Created by DmitrySK on 21.05.2025.
//

import UIKit

class NewsViewModel: INewsViewModel {
    
    private let repository: INewsRepository
    var snapshotDidChange: ((Snapshot) -> ())? = nil
    
    private var snapshot: Snapshot!
    private var currentPage: Int = 1
    private var isLoading: Bool = true
    private var hasMoreToLoad: Bool = true
    
    init(repository: INewsRepository, snapshotDidChange: ((Snapshot) -> Void)? = nil) {
        self.repository = repository
        self.snapshotDidChange = snapshotDidChange
        self.setupSnapshot()
    }
    
    private func setupSnapshot() {
        snapshot = Snapshot()
        snapshot.appendSections([.main])
    }
    
    func fetchNews() {
        isLoading = true
        Task {
            do {
                let news = try await repository.fetchNews(page: currentPage)
                hasMoreToLoad = news.count > 0
                updateSnapshot(with: news)
                DispatchQueue.main.async {
                    self.snapshotDidChange?(self.snapshot)
                    self.isLoading = false
                }
            } catch {
                self.isLoading = false
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateSnapshot(with news: [News]){
        let items = news.map { NewsViewItem(id: $0.id, title: $0.title, imageUrl: $0.titleImageUrl) }
        snapshot.appendItems(items, toSection: .main)
    }
    
    func didScrollToEnd() {
        guard !isLoading, hasMoreToLoad else { return }
        currentPage += 1
        fetchNews()
    }
}
