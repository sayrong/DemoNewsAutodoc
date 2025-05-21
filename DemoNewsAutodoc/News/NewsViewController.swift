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
}


class NewsViewController: UIViewController {
    
    private var viewModel: INewsViewModel
    private var dataSource: UICollectionViewDiffableDataSource<NewsCollectionSection, NewsViewItem>!
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(NewsCollectionViewCell.self, forCellWithReuseIdentifier: NewsCollectionViewCell.reuseIdentifier)
        return collectionView
    }()
    
    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search news"
        return searchController
    }()
    
    init(viewModel: INewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setupSearchController()
        setupDataSource()
        setupDelegate()
        bindViewModel()
        viewModel.fetchNews()
    }
    
    private func addSubviews() {
        view.addSubview(collectionView)
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.delegate = self
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<NewsCollectionSection, NewsViewItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsCollectionViewCell.reuseIdentifier, for: indexPath)
                    as? NewsCollectionViewCell else {
                return nil
            }
            cell.configure(with: item)
            return cell
        }
    }
    
    private func setupDelegate() {
        collectionView.delegate = self
    }
    
    private func bindViewModel() {
        viewModel.snapshotDidChange = { [weak self] snapshot in
            self?.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            
            let itemWidth: CGFloat = 375
            let itemHeight: CGFloat = 200
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth),
                                                  heightDimension: .absolute(itemHeight))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(itemHeight))
            
            let itemsPerRow = UIDevice.current.userInterfaceIdiom == .pad ? max(2, Int(environment.container.contentSize.width / itemWidth)) : 1
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: itemsPerRow)
            
            // Вычисляем отступы для центрирования группы
            let containerWidth = environment.container.contentSize.width
            let groupWidth = CGFloat(itemsPerRow) * itemWidth + CGFloat(itemsPerRow - 1) * 8 // itemWidth * count + spacing
            let inset = max(0, (containerWidth - groupWidth) / 2) // Центрирующий отступ
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: inset, bottom: 0, trailing: inset)
            
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
