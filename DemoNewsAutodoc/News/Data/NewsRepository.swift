//
//  NewsService.swift
//  DemoNewsAutodoc
//
//  Created by DmitrySK on 20.05.2025.
//

import UIKit

protocol INewsRepository {
    var pageSize: Int {get set}
    func fetchNews(page: Int) async throws -> [News]
}


final class NewsRepository: INewsRepository {
    
    let network: URLSession
    var pageSize: Int
    
    init(network: URLSession = URLSession.shared, pageSize: Int = 15) {
        self.network = network
        self.pageSize = pageSize
    }
    
    func fetchNews(page: Int) async throws -> [News] {
        let url = URL(string: "https://webapi.autodoc.ru/api/news/\(page)/\(pageSize)")!
        let (data, _) = try await network.data(from: url)
        let response = try JSONDecoder().decode(NewsResponse.self, from: data)
        return response.news.compactMap { News.convert(from: $0) }
    }
}
