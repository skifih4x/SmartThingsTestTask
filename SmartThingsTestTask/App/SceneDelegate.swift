//
//  SceneDelegate.swift
//  SmartThingsTestTask
//
//  Created by Артем Орлов on 07.07.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let appBuilder = AppBuilder()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        let mainViewController = appBuilder.buildMainViewController()
        window?.rootViewController = mainViewController
        window?.makeKeyAndVisible()
    }
}

