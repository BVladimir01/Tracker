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
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            assertionFailure("SceneDelegate.scene: Failed to get appDelegate")
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        guard let categoryStore = try? CategoryStore(context: context) else {
            assertionFailure("SceneDelegate.scene: Failed to initialize trackerCategoryStore")
            return
        }
        do {
            let trackerStore = try TrackerStore(context: context)
            let recordStore = RecordStore(context: context)
            window = UIWindow(windowScene: windowScene)
            window?.rootViewController = TabBarController(stores:
                                                            TrackerDataStores(trackerStore: trackerStore,
                                                                              trackerCategoryStore: categoryStore,
                                                                              trackerRecordStore: recordStore))
            window?.makeKeyAndVisible()
        } catch {
            assertionFailure("SceneDelegate.scene: error \(error)")
        }
    }


}

