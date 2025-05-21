//
//  News.swift
//  DemoNewsAutodoc
//
//  Created by DmitrySK on 21.05.2025.
//

import Foundation

struct News {
    let id: Int
    let title: String
    let description: String
    let publishedDate: Date
    let titleImageUrl: URL
    let fullUrl: URL
    let categoryType: String
        
    static func convert(from dto: NewsDTO) -> News? {
        guard let title = dto.title,
              let description = dto.description,
              let category = dto.categoryType,
              let fullUrlString = dto.fullUrl,
              let publishedDate = dto.publishedDate.flatMap({ News.stringToDate($0) }),
              let titleImageUrl = dto.titleImageUrl.flatMap({ URL(string: $0) }),
              let fullUrl = URL(string: fullUrlString) else {
            return nil
        }
        return .init(id: dto.id, title: title, description: description,
                     publishedDate: publishedDate, titleImageUrl: titleImageUrl,
                     fullUrl: fullUrl, categoryType: category)
    }

    static func stringToDate(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        return formatter.date(from: string)
    }
}
