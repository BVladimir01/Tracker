//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Vladimir on 01.05.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        do {
            let stores = try TrackerDataStores()
            window = UIWindow(windowScene: windowScene)
            window?.rootViewController = TabBarController(stores: stores)
            window?.makeKeyAndVisible()
        } catch {
            assertionFailure("SceneDelegate.scene: error \(error)")
        }
    }


}

