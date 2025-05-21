//
//  ImageLoader.swift
//  DemoNewsAutodoc
//
//  Created by DmitrySK on 21.05.2025.
//

import UIKit
import ImageIO

class ImageLoader {
    
    static let shared = ImageLoader()
    
    private let imageCache = NSCache<NSURL, UIImage>()
    
    init() {
        imageCache.countLimit = 200
    }
    
    func loadImage(from url: URL) async throws -> UIImage {
        if let cached = imageCache.object(forKey: url as NSURL) {
            return cached
        }
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
