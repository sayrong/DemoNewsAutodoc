//
//  NewsViewController.swift
//  DemoNewsAutodoc
//
//  Created by DmitrySK on 20.05.2025.
//

import UIKit

protocol INewsViewModel {
    
    typealias Snapshot = NSDiffableDataSourceSnapshot<NewsCollectionSection, NewsViewItem>
    
    var snapshotDidChange: ((Snapshot) -> ())? { get set }
    func fetchNews()
    func didScrollToEnd()
    func didTapOnCell(with id: Int)
    func didSearchTextChanged(to query: String)
    func reloadData()
}


class NewsViewController: UIViewController {
    
    private var viewModel: INewsViewModel
    private var dataSource: UICollectionViewDiffableDataSource<NewsCollectionSection, NewsViewItem>!
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.register(NewsCollectionViewCell.self, forCellWithReuseIdentifier: NewsCollectionViewCell.reuseIdentifier)
        return collectionView
    }()
    
    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search news"
        return searchController
    }()
    
    private lazy var refreshControl = UIRefreshControl()
    
    init(viewModel: INewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCollectionView()
        setupSearchController()
        setupRefresh()
        setupDataSource()
        setupDelegate()
        bindViewModel()
        viewModel.fetchNews()
    }
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.delegate = self
    }
    
    private func setupRefresh() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    @objc private func refreshData() {
        viewModel.reloadData()
    }
    
    private func setupDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration<NewsCollectionViewCell, NewsViewItem> { cell, indexPath, item in
            cell.configure(with: item)
        }
        
        dataSource = UICollectionViewDiffableDataSource<NewsCollectionSection, NewsViewItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
    
    private func setupDelegate() {
        collectionView.delegate = self
    }
    
    private func bindViewModel() {
        viewModel.snapshotDidChange = { [weak self] snapshot in
            guard let self = self else { return }
            self.dataSource.apply(snapshot, animatingDifferences: true)
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            
            let desiredItemWidth: CGFloat = 300
            let itemHeight: CGFloat = 200
            let spacing: CGFloat = 8
            let itemHorizontalInset: CGFloat = 16
            
            let availableWidth = environment.container.contentSize.width
            //Общая ширина = N * itemWidth + (N-1) * spacing
            let itemsPerRow = max(1, Int((availableWidth + spacing) / (desiredItemWidth + spacing)))
            let actualItemWidth = (availableWidth - CGFloat(itemsPerRow - 1) * spacing) / CGFloat(itemsPerRow)

            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(actualItemWidth),
                                                  heightDimension: .absolute(itemHeight))

            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: itemHorizontalInset, bottom: spacing, trailing: itemHorizontalInset)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(200)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: itemsPerRow)

            let section = NSCollectionLayoutSection(group: group)
            return section
        }
    }
}

extension NewsViewController: UICollectionViewDelegate, UIScrollViewDelegate  {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.didTapOnCell(with: item.id)
    }
    
    // Пагинация
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.bounds.height
        
        let distanceToBottom = contentHeight - offsetY - frameHeight
        
        if distanceToBottom > 0 && distanceToBottom < 200 {
            viewModel.didScrollToEnd()
        }
    }
}

extension NewsViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        viewModel.didSearchTextChanged(to: query)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}
