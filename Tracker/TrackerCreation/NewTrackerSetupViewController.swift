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
    
    private var createButtonEnabled = false {
        didSet {
            if createButtonEnabled {
                createButton.isEnabled = true
                createButton.backgroundColor = LayoutConstants.Buttons.createButtonBackgroundColor
                createButton.titleLabel?.textColor = LayoutConstants.Buttons.createButtonTextColor
            } else {
                createButton.isEnabled = false
                createButton.backgroundColor = LayoutConstants.Buttons.createButtonDisabledColor
                createButton.titleLabel?.textColor = LayoutConstants.Buttons.createButtonDisabledTextColor
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setUpTitle()
        setUpNameTextField()
        setUpCancelButton()
        setUpCreateButton()
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
    
    private func setUpCancelButton() {
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(LayoutConstants.Buttons.cancelButtonColor, for: .normal)
        cancelButton.titleLabel?.font = LayoutConstants.Buttons.font
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.layer.cornerRadius = LayoutConstants.Buttons.cornerRadius
        cancelButton.layer.borderWidth = LayoutConstants.Buttons.cancelButtonBorderWidth
        cancelButton.layer.borderColor = LayoutConstants.Buttons.cancelButtonColor.cgColor
        
        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                  constant: LayoutConstants.Buttons.lateralPadding),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                 constant: LayoutConstants.Buttons.bottomPadding),
            cancelButton.widthAnchor.constraint(equalToConstant: LayoutConstants.Buttons.cancelButtonWidth),
            cancelButton.heightAnchor.constraint(equalToConstant: LayoutConstants.Buttons.height)
        ])
    }
    
    private func setUpCreateButton() {
        createButton.setTitle("Создать", for: .normal)
        createButton.backgroundColor = LayoutConstants.Buttons.createButtonBackgroundColor
        createButton.setTitleColor(LayoutConstants.Buttons.createButtonTextColor, for: .normal)
        createButton.titleLabel?.font = LayoutConstants.Buttons.font
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        createButton.layer.cornerRadius = LayoutConstants.Buttons.cornerRadius
        createButtonEnabled = false
        
        view.addSubview(createButton)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            createButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                  constant: -LayoutConstants.Buttons.lateralPadding),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                 constant: LayoutConstants.Buttons.bottomPadding),
            createButton.widthAnchor.constraint(equalToConstant: LayoutConstants.Buttons.createButtonWidth),
            createButton.heightAnchor.constraint(equalToConstant: LayoutConstants.Buttons.height)
        ])
    }
    
    
    @objc
    private func cancelButtonTapped() {
        // TODO: implement cancel button tap
    }
    
    @objc
    private func createButtonTapped() {
        // TODO: implement create button tap
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
        enum Buttons {
            static let cancelButtonColor: UIColor = .ypRed
            static let cancelButtonBackgroundColor: UIColor = .ypWhite
            static let cancelButtonBorderWidth: CGFloat = 1
            static let cancelButtonWidth: CGFloat = 166
            
            static let createButtonBackgroundColor: UIColor = .ypBlack
            static let createButtonTextColor: UIColor = .ypWhite
            static let createButtonDisabledColor: UIColor = .ypGray
            static let createButtonDisabledTextColor: UIColor = .white
            static let createButtonWidth: CGFloat = 161
            
            static let bottomPadding: CGFloat = 0
            static let lateralPadding: CGFloat = 20
            static let height: CGFloat = 60
            static let font: UIFont = .systemFont(ofSize: 16, weight: .medium)
            static let cornerRadius: CGFloat = 16
        }
    }
}
