//
//  NewsViewController.swift
//  DemoNewsAutodoc
//
//  Created by DmitrySK on 20.05.2025.
//

import UIKit
import Combine

protocol INewsViewModel {
    // ViewState
    var statePublisher: AnyPublisher<NewsListState, Never> { get }
    // Methods to interact
    func fetchNews()
    func didScrollToEnd()
    func didTapOnCell(with id: Int)
    func didSearchTextChanged(to query: String)
    func reloadData()
}


class NewsViewController: UIViewController {
    
    private var viewModel: INewsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: UI Elements
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
    private var loadingIndicator: UIActivityIndicatorView?
    
    // MARK: VC Lifecycle
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
        setupLoadingIndicator()
        setupDataSource()
        setupDelegate()
        bindViewModel()
    }
    
    // MARK: UI Setup
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
    
    private func setupLoadingIndicator() {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        loadingIndicator = indicator
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
    
    // MARK: Bind and state render
    private func bindViewModel() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state: state)
            }
            .store(in: &cancellables)
    }
    
    private func render(state: NewsListState) {
        switch state {
        case .idle:
            viewModel.fetchNews()
        case .initialLoading:
            loadingIndicator?.startAnimating()
        case .loadingMore:
            break
        case .loaded(let snapshot):
            loadingIndicator?.stopAnimating()
            dataSource.apply(snapshot, animatingDifferences: true)
            refreshControl.endRefreshing()
        case .error(let message):
            loadingIndicator?.stopAnimating()
            refreshControl.endRefreshing()
            showError(message)
        }
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
    
    
    // MARK: Collection Layout
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
