//
//  NewsDTO.swift
//  DemoNewsAutodoc
//
//  Created by DmitrySK on 21.05.2025.
//

struct NewsResponse: Decodable {
    let news: [NewsDTO]
}

struct NewsDTO: Codable {
    let id: Int
    let title: String?
    let description: String?
    let publishedDate: String?
    let url: String?
    let fullUrl: String?
    let titleImageUrl: String?
    let categoryType: String?
}
