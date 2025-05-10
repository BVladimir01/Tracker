//
//  NewTrackerTypeViewController.swift
//  Tracker
//
//  Created by Vladimir on 10.05.2025.
//

import UIKit


// MARK: - NewTracerViewController
final class NewTrackerViewController: UIViewController {
    
    // MARK: - Private Properties
    private let regularTrackerButton = UIButton(type: .system)
    private let irregularTrackerButton = UIButton(type: .system)
    
    private let irregularTrackerTitle = "Нерегулярное событие"
    private let regularTrackerTitle = "Привычка"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setUpTitle()
        setUpRegularTrackerButton()
        setUpIrregularTrackerButton()
    }
    
    // MARK: - Private Methods - Setup
    
    private func setUpTitle() {
        let title = UILabel()
        title.text = "Создание трекера"
        title.font = LayoutConstants.titleFont
        title.textColor = LayoutConstants.titleTextColor
        title.textAlignment = .center
        
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: LayoutConstants.titleTopPadding)
        ])
    }
    
    private func setUpRegularTrackerButton() {
        regularTrackerButton.setTitle(regularTrackerTitle, for: .normal)
        regularTrackerButton.setTitleColor(LayoutConstants.buttonTextColor, for: .normal)
        regularTrackerButton.titleLabel?.font = LayoutConstants.buttonTitleFont
        regularTrackerButton.addTarget(self, action: #selector(didTapCreate(_:)), for: .touchUpInside)
        
        regularTrackerButton.layer.cornerRadius = LayoutConstants.buttonCornerRadius
        regularTrackerButton.backgroundColor = LayoutConstants.buttonColor
        
        view.addSubview(regularTrackerButton)
        regularTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            regularTrackerButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            regularTrackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                      constant: LayoutConstants.buttonTopPadding),
            regularTrackerButton.heightAnchor.constraint(equalToConstant: LayoutConstants.buttonHeight),
            regularTrackerButton.widthAnchor.constraint(equalToConstant: LayoutConstants.buttonWidth)
        ])
        
    }
    
    private func setUpIrregularTrackerButton() {
        irregularTrackerButton.setTitle(irregularTrackerTitle, for: .normal)
        irregularTrackerButton.setTitleColor(LayoutConstants.buttonTextColor, for: .normal)
        irregularTrackerButton.titleLabel?.font = LayoutConstants.buttonTitleFont
        irregularTrackerButton.addTarget(self, action: #selector(didTapCreate(_:)), for: .touchUpInside)
        
        irregularTrackerButton.layer.cornerRadius = LayoutConstants.buttonCornerRadius
        irregularTrackerButton.backgroundColor = LayoutConstants.buttonColor
        
        view.addSubview(irregularTrackerButton)
        irregularTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            irregularTrackerButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            irregularTrackerButton.topAnchor.constraint(equalTo: regularTrackerButton.bottomAnchor,
                                                      constant: LayoutConstants.buttonsSpacing),
            irregularTrackerButton.heightAnchor.constraint(equalToConstant: LayoutConstants.buttonHeight),
            irregularTrackerButton.widthAnchor.constraint(equalToConstant: LayoutConstants.buttonWidth)
        ])
    }
    
    // MARK: - Private Methods - Intentions
    
    @objc private func didTapCreate(_ sender: UIButton) {
        guard let buttonTitle = sender.title(for: .normal) else {
            assertionFailure("NewTrackerViewController.didTapCreate: Failed to get title of the button")
            return
        }
        var createRegularTracker: Bool
        if buttonTitle == regularTrackerTitle {
            createRegularTracker = true
        } else if buttonTitle == irregularTrackerTitle {
            createRegularTracker = false
        } else {
            assertionFailure("NewTrackerViewController.didTapCreate: unknown title")
            return
        }
        let newTrackerSetupVC = NewTrackerSetupViewController()
        newTrackerSetupVC.trackerIsRegular = createRegularTracker
        present(newTrackerSetupVC, animated: true)
    }
    
}


// MARK: - LayoutConstants
extension NewTrackerViewController {
    enum LayoutConstants {
        static let titleFont: UIFont = .systemFont(ofSize: 16, weight: .medium)
        static let titleTextColor: UIColor = .ypBlack
        static let titleTopPadding: CGFloat = 27
        
        static let buttonTitleFont: UIFont = .systemFont(ofSize: 16, weight: .medium)
        static let buttonColor: UIColor = .ypBlack
        static let buttonTextColor: UIColor = .ypWhite
        static let buttonWidth: CGFloat = 335
        static let buttonHeight: CGFloat = 60
        static let buttonCornerRadius: CGFloat = 16
        
        static let buttonTopPadding: CGFloat = 344
        static let buttonsSpacing: CGFloat = 16
        
    }
}
