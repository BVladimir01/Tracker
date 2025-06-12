//
//  ViewController.swift
//  Tracker
//
//  Created by Vladimir on 01.05.2025.
//

import UIKit


final class TabBarController: UITabBarController {
    
    let stores: TrackerDataStores
    
    // MARK: - Lifecycle
    
    init(stores: TrackerDataStores) {
        self.stores = stores
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        addViewControllers()
        setUpTabBar()
    }
    
    // MARK: - Private Methods
    
    private func addViewControllers() {
        let trackerNavController = setUpAndReturnTrackerNavStack()
        let statsNavController = setUpAndReturnStatsNavStack()
        viewControllers = [trackerNavController, statsNavController]
    }
    
    private func setUpAndReturnTrackerNavStack() -> UIViewController {
        let trackersVC = TrackersListViewController(trackerDataStores: stores)
        let trackerNavController = UINavigationController(rootViewController: trackersVC)
        trackerNavController.navigationBar.prefersLargeTitles = true
        trackerNavController.tabBarItem = UITabBarItem(title: Strings.trackersTitle,
                                                       image: .tabBarTrackerItem.withTintColor(.ypBlue),
                                                       selectedImage: .tabBarTrackerItem.withTintColor(.ypGray))
        return trackerNavController
    }
    
    private func setUpAndReturnStatsNavStack() -> UIViewController {
        let statsVC = StatsViewController()
        let statsNavController = UINavigationController(rootViewController: statsVC)
        statsNavController.navigationBar.prefersLargeTitles = true
        statsNavController.tabBarItem = UITabBarItem(title: Strings.statsTitle,
                                                     image: .tabBarStatsItem.withTintColor(.ypBlue),
                                                     selectedImage: .tabBarStatsItem.withTintColor(.ypGray))
        return statsNavController
    }

    private func setUpTabBar() {
        let separatorHeight: CGFloat = 0.5
        let separator = UIView()
        
        separator.backgroundColor = .ypBackground
        tabBar.addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: tabBar.topAnchor),
            separator.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: separatorHeight)
        ])
        
        tabBar.backgroundColor = .ypWhite
    }

}


// MARK: - Strings
extension TabBarController {
    enum Strings {
        static let trackersTitle = NSLocalizedString("trackersListTab.nav_title", comment: "")
        static let statsTitle = NSLocalizedString("statsTab.nav_title", comment: "")
    }
}
