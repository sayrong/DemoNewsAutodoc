//
//  NewsRouter.swift
//  DemoNewsAutodoc
//
//  Created by DmitrySK on 21.05.2025.
//

import UIKit

class NewsRouter: INewsRouter {
    
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }
    
    func openDetails(for news: News) {
        let newVC = WebViewController(url: news.fullUrl)
        newVC.modalPresentationStyle = .pageSheet
        viewController?.present(newVC, animated: true)
    }
}
