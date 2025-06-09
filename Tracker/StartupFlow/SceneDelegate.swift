//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Vladimir on 01.05.2025.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        if OnboardingStatusStore.shared.shouldShowOnboarding {
            window?.rootViewController = OnboardingViewController()
        } else {
            do {
                let stores = try TrackerDataStores()
                window?.rootViewController = TabBarController(stores: stores)
            } catch {
                assertionFailure("SceneDelegate.scene: error \(error)")
            }
        }
        window?.makeKeyAndVisible()
    }
}

