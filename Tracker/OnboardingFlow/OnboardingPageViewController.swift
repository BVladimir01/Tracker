//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Vladimir on 08.06.2025.
//


import UIKit


// MARK: - OnboardingPageViewController
final class OnboardingPageViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let text: String
    private let backgroundImage: UIImage

    private let titleLabel = UILabel()
    private var constraints: [NSLayoutConstraint] = []
    
    // MARK: - Initializers
    
    init(title: String, backgroundImage: UIImage) {
        self.text = title
        self.backgroundImage = backgroundImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBackground()
        setUpTitleLabel()
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Private Methods - Setup
    
    private func setUpTitleLabel() {
        titleLabel.text = text
        titleLabel.textColor = LayoutConstants.Title.textColor
        titleLabel.font = LayoutConstants.Title.font
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = LayoutConstants.Title.numberOfLines
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        constraints.append(contentsOf: [
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                            constant: LayoutConstants.Title.spacingToTopView),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: LayoutConstants.Title.width)
        ])
    }
    
    private func setUpBackground() {
        let background = UIImageView(image: backgroundImage)
        background.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(background)
        
        constraints.append(contentsOf: [
            background.topAnchor.constraint(equalTo: view.topAnchor),
            background.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            background.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

}


// MARK: - Layout Constants
extension OnboardingPageViewController {
    enum LayoutConstants {
        enum Title {
            static let spacingToTopView: CGFloat = 388
            static let font = UIFont.systemFont(ofSize: 32, weight: .bold)
            static let textColor: UIColor = .alwaysBlack
            static let width: CGFloat = 343
            static let numberOfLines = 2
        }
    }
}
