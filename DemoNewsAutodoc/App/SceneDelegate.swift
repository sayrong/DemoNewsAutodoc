//
//  SceneDelegate.swift
//  DemoNewsAutodoc
//
//  Created by DmitrySK on 20.05.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let newsRepository = NewsRepository()
        let router = NewsRouter()
        let newsVM = NewsViewModel(repository: newsRepository, router: router)
        let rootViewController = NewsViewController(viewModel: newsVM)
        router.viewController = rootViewController
        
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
}

