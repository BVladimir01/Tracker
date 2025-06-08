//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Vladimir on 08.06.2025.
//


import UIKit


final class OnboardingPageViewController: UIViewController {
    
    private let text: String
    private let backgroundImage: UIImage
    
    private let button = UIButton(type: .system)
    private let titleLabel = UILabel()
    private var constraints: [NSLayoutConstraint] = []
    
    init(title: String, backgroundImage: UIImage) {
        self.text = title
        self.backgroundImage = backgroundImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTitleLabel()
        setUpButton()
    }
    
    private func setUpTitleLabel() {
        titleLabel.text = text
        titleLabel.textColor = LayoutConstants.Title.textColor
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        constraints.append(contentsOf: [
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                            constant: LayoutConstants.Title.spacingToTopView),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    private func setUpButton() {
        button.setTitle("Вот это технологии", for: .normal)
        button.tintColor = LayoutConstants.Button.color
        button.titleLabel?.textColor = LayoutConstants.Button.textColor
        button.titleLabel?.font = LayoutConstants.Button.font
        button.layer.cornerRadius = LayoutConstants.Button.cornerRadius
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        constraints.append(contentsOf: [
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                           constant: -LayoutConstants.Button.spacingToBottomView),
            button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    @objc
    private func buttonTapped() {
        // TODO: implement
    }
}


extension OnboardingPageViewController {
    enum LayoutConstants {
        enum Title {
            static let spacingToTopView: CGFloat = 388
            static let font = UIFont.systemFont(ofSize: 32, weight: .bold)
            static let textColor: UIColor = .ypBlack
            
        }
        enum Button {
            static let color: UIColor = .ypBlack
            static let textColor: UIColor = .ypWhite
            static let font = UIFont.systemFont(ofSize: 16, weight: .medium)
            static let cornerRadius: CGFloat = 16
            static let height: CGFloat = 60
            static let width: CGFloat = 33
            static let spacingToBottomView: CGFloat = 69
        }
    }
}
