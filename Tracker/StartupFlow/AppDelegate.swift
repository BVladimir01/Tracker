//
//  AppDelegate.swift
//  Tracker
//
//  Created by Vladimir on 01.05.2025.
//

import UIKit
import CoreData

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AnalyticsService.activate()
        return true
    }
}

