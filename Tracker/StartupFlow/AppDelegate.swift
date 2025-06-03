//
//  AppDelegate.swift
//  Tracker
//
//  Created by Vladimir on 01.05.2025.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    lazy var persistentContainer: NSPersistentContainer = {
       let container = NSPersistentContainer(name: "TrackerDataModel")
        container.loadPersistentStores { description, error in
            if let error {
                assertionFailure("AppDelegate: \(error.localizedDescription)")
            }
        }
        return container
    }()
}

