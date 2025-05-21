//
//  String+.swift
//  DemoNewsAutodoc
//
//  Created by DmitrySK on 21.05.2025.
//

extension String {
    
    static func randomLoremIpsum(length: Int) -> String {
        let lorem = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
        let words = lorem.split(separator: " ")
        let selectedWords = (0..<length).map { _ in words.randomElement()! }
        return selectedWords.joined(separator: " ")
    }
}
