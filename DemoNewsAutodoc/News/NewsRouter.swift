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
        
        let navController = UINavigationController(rootViewController: newVC)
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: newVC, action: #selector(WebViewController.closeAction))
        newVC.navigationItem.leftBarButtonItem = closeButton
        
        navController.modalPresentationStyle = .pageSheet
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        viewController?.present(navController, animated: true)
    }
}
