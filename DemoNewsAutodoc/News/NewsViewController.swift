//
//  NewsViewController.swift
//  DemoNewsAutodoc
//
//  Created by DmitrySK on 20.05.2025.
//

import UIKit

class NewsViewController: UIViewController {
    
    enum Section: Hashable {
        case main
    }
    
    struct Item: Hashable {
        let id = UUID()
        let title: String
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        //чтобы следовал за superview
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(NewsCollectionViewCell.self, forCellWithReuseIdentifier: NewsCollectionViewCell.reuseIdentifier)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
 
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsCollectionViewCell.reuseIdentifier, for: indexPath)
            // Настройка ячейки
            return cell
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems([
            Item(title: "Item 1"),
            Item(title: "Item 2"),
            Item(title: "Item 3")
        ])
        dataSource.apply(snapshot, animatingDifferences: false)
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

