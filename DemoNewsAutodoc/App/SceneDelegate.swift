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
        let newsVM = NewsViewModel(repository: newsRepository)
        let rootViewController = NewsViewController(viewModel: newsVM)

        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
}

