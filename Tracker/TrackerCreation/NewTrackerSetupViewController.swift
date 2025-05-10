//
//  NewTrackerSetupViewController.swift
//  Tracker
//
//  Created by Vladimir on 10.05.2025.
//

import UIKit


// MARK: - NewTrackerSetupViewController
final class NewTrackerSetupViewController: UIViewController {
    
    var trackerIsRegular = true
    
    private let nameTextField = UITextField()
    private let cancelButton = UIButton(type: .system)
    private let createButton = UIButton(type: .system)
    private let table = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setUpTitle()
        setUpNameTextField()
    }
    
    private func setUpTitle() {
        let title = UILabel()
        title.text = "Новый трекер"
        title.font = LayoutConstants.Title.font
        title.textColor = LayoutConstants.Title.textColor
        title.textAlignment = .center
        
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                       constant: LayoutConstants.Title.topPadding)
        ])
    }
    
    private func setUpNameTextField() {
        nameTextField.placeholder = LayoutConstants.TextField.placeHolder
        nameTextField.borderStyle = .roundedRect
        nameTextField.layer.cornerRadius = LayoutConstants.TextField.cornerRadius
        nameTextField.layer.masksToBounds = true
        nameTextField.textColor = LayoutConstants.TextField.textColor
        nameTextField.backgroundColor = LayoutConstants.TextField.backgroundColor
        
        view.addSubview(nameTextField)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameTextField.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                               constant: LayoutConstants.TextField.topPadding),
            nameTextField.widthAnchor.constraint(equalToConstant: LayoutConstants.TextField.width),
            nameTextField.heightAnchor.constraint(equalToConstant: LayoutConstants.TextField.height)
        ])
    }
}


// LayoutConstants
extension NewTrackerSetupViewController {
    enum LayoutConstants {
        enum Title {
            static let font: UIFont = .systemFont(ofSize: 16, weight: .medium)
            static let textColor: UIColor = .ypBlack
            static let topPadding: CGFloat = 27
        }
        enum TextField {
            static let placeHolder = "Введите название трекера"
            static let backgroundColor: UIColor = .ypBackground
            static let font: UIFont = .systemFont(ofSize: 17, weight: .regular)
            static let textColor: UIColor = .ypBlack
            static let cornerRadius: CGFloat = 16
            static let topPadding: CGFloat = 87
            static let width: CGFloat = 343
            static let height: CGFloat = 75
        }
    }
}
