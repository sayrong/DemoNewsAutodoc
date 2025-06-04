//
//  ImageLoader.swift
//  DemoNewsAutodoc
//
//  Created by DmitrySK on 21.05.2025.
//

import UIKit
import ImageIO

actor ImageLoader {
    
    static let shared = ImageLoader()
    
    private let imageCache = NSCache<NSURL, UIImage>()
    private var runningRequests: [URL: Task<UIImage, Error>] = [:]
    
    init() {
        imageCache.countLimit = 200
    }
    
    func loadImage(from url: URL) async throws -> UIImage {
        try Task.checkCancellation()
        
        if let cached = imageCache.object(forKey: url as NSURL) {
            return cached
        }
        
        if let existingTask = runningRequests[url] {
            return try await existingTask.value
        }
        
        let task = Task<UIImage, Error> {
            try await self.processImage(url)
        }
        runningRequests[url] = task
        defer { runningRequests.removeValue(forKey: url) }
        
        return try await task.value
    }
    
    private func processImage(_ url: URL) async throws -> UIImage {
        try Task.checkCancellation()
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let image = createThumbnail(from: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        imageCache.setObject(image, forKey: url as NSURL)
        return image
    }
    
    private func createThumbnail(from imageData: Data, maxPixelSize: Int = 350) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
            kCGImageSourceCreateThumbnailWithTransform: true
        ]
        
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}
