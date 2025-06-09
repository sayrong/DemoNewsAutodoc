//
//  NewsCollectionSection.swift
//  DemoNewsAutodoc
//
//  Created by DmitrySK on 21.05.2025.
//

import Foundation

enum NewsCollectionSection: Hashable {
    case main
}

enum NewsCollectionViewItem: Hashable {
    case news(NewsViewItem)
    case loading
}

struct NewsViewItem: Hashable {
    let id: Int
    let title: String
    let imageUrl: URL
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
