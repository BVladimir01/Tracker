//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Vladimir on 08.06.2025.
//

import UIKit


final class OnboardingViewController: UIPageViewController {
    
    private let pages: [UIViewController]
    private let pageControl = UIPageControl()
    private let button = UIButton(type: .system)
    private var constraints: [NSLayoutConstraint] = []
    
    init() {
        pages = [("Отслеживайте только то, что хотите", UIImage.firstOnboardingPage),
                 ("Даже если это не литры воды и йога", UIImage.secondOnboardingPage)].map { (text, image) in
            OnboardingPageViewController(title: text, backgroundImage: image)
            }
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        setViewControllers([pages[0]], direction: .forward, animated: true)
        setUpButton()
        setUpPageControl()
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setUpPageControl() {
        pageControl.currentPage = 0
        pageControl.numberOfPages = pages.count
        pageControl.currentPageIndicatorTintColor = LayoutConstants.PageControl.currentPageIndicatorTintColor
        pageControl.pageIndicatorTintColor = LayoutConstants.PageControl.pageIndicatorTintColor
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        
        constraints.append(contentsOf: [
            pageControl.bottomAnchor.constraint(equalTo: button.topAnchor,
                                                constant: -LayoutConstants.PageControl.spacingToBottomView),
            pageControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    private func setUpButton() {
        button.setTitle("Вот это технологии", for: .normal)
        button.backgroundColor = LayoutConstants.Button.color
        button.tintColor = LayoutConstants.Button.textColor
        button.titleLabel?.textColor = LayoutConstants.Button.textColor
        button.titleLabel?.font = LayoutConstants.Button.font
        button.layer.cornerRadius = LayoutConstants.Button.cornerRadius
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        constraints.append(contentsOf: [
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                           constant: -LayoutConstants.Button.spacingToBottomView),
            button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            button.heightAnchor.constraint(equalToConstant: LayoutConstants.Button.height),
            button.widthAnchor.constraint(equalToConstant: LayoutConstants.Button.width)
        ])
    }
    
    @objc
    private func buttonTapped() {
        do {
            let stores = try TrackerDataStores()
            let tabBarController = TabBarController(stores: stores)
            guard let window = view.window else {
                assertionFailure("OnboardingViewController.buttonTapped: failed to get window")
                return
            }
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
                window.rootViewController = tabBarController
            }
            window.rootViewController = tabBarController
            OnboardingStatusStore.shared.userDidPassOnboarding()
        } catch {
            print(error)
            assertionFailure("OnboardingViewController.buttonTapped: failed to initialize DataStores")
        }
    }
    
}


extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController == pages[1] {
            return pages[0]
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController == pages[0] {
            return pages[1]
        } else {
            return nil
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentViewController = pageViewController.viewControllers?.first, let currentIndex = pages.firstIndex(of: currentViewController) else {
            assertionFailure("OnboardingViewController.pageViewController: failed to get index of viewController")
            return
        }
        pageControl.currentPage = currentIndex
    }
    
}


extension OnboardingViewController {
    enum LayoutConstants {
        enum PageControl {
            static let currentPageIndicatorTintColor: UIColor = .ypBlack
            static let pageIndicatorTintColor: UIColor = .ypBlack.withAlphaComponent(0.3)
            static let spacingToBottomView: CGFloat = 24
        }
        
        enum Button {
            static let color: UIColor = .ypBlack
            static let textColor: UIColor = .ypWhite
            static let font = UIFont.systemFont(ofSize: 16, weight: .medium)
            static let cornerRadius: CGFloat = 16
            static let height: CGFloat = 60
            static let width: CGFloat = 335
            static let spacingToBottomView: CGFloat = 69
        }
    }
}
