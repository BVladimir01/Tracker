//
//  CategoryCreationViewController.swift
//  Tracker
//
//  Created by Vladimir on 10.05.2025.
//

import UIKit


// MARK: CategoryCreationViewControllerDelegate
protocol CategoryCreationViewControllerDelegate: AnyObject {
    func categoryCreationViewControllerDelegate(_ vc: UIViewController, didCreateCategory category: TrackerCategory)
}


// MARK: - CategoryCreationViewController
final class CategoryCreationViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private var categoryStore: CategoryStoreProtocol
    private weak var delegate: CategoryCreationViewControllerDelegate?
    
    private let titleLabel = UILabel()
    private let textField = TrackerTextFieldView()
    private let doneButton = UIButton(type: .system)
    
    private var shouldEnableDoneButton: Bool {
        if let text = textField.text, text.count <= LayoutConstants.TextField.maxTextLength {
            !text.isEmpty
        } else {
            false
        }
    }
    
    // MARK: Initializers
    
    init(categoryStore: CategoryStoreProtocol, delegate: CategoryCreationViewControllerDelegate) {
        self.categoryStore = categoryStore
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init not implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LayoutConstants.backgroundColor
        setUpTitle()
        setUpTextField()
        setUpDoneButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    // MARK: - Private Methods - Setup
    
    private func setUpTitle() {
        titleLabel.text = Strings.title
        titleLabel.font = LayoutConstants.Title.font
        titleLabel.textColor = LayoutConstants.Title.textColor
        titleLabel.textAlignment = .center
        
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                       constant: LayoutConstants.Title.spacingToSuperviewTop)
        ])
    }
    
    private func setUpTextField() {
        textField.delegate = self
        textField.onTextChange = { [weak self] text in
            self?.updateDoneButtonState()
        }
        textField.placeholder = Strings.textFieldPlaceholderTitle
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                               constant: LayoutConstants.TextField.topPadding),
            textField.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            textField.widthAnchor.constraint(equalToConstant: LayoutConstants.TextField.width),
        ])
    }
    
    private func setUpDoneButton() {
        doneButton.setTitle(Strings.doneButtonTitle, for: .normal)
        doneButton.titleLabel?.font = LayoutConstants.Button.font
        doneButton.setTitleColor(LayoutConstants.Button.textColor, for: .normal)
        doneButton.backgroundColor = LayoutConstants.Button.disabledBackgroundColor
        doneButton.isEnabled = false
        doneButton.layer.cornerRadius = LayoutConstants.Button.cornerRadius
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        
        view.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            doneButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                               constant: -LayoutConstants.Button.spacingToSuperviewBottom),
            doneButton.widthAnchor.constraint(equalToConstant: LayoutConstants.Button.width),
            doneButton.heightAnchor.constraint(equalToConstant: LayoutConstants.Button.height)
        ])
        
        updateDoneButtonState()
    }
    
    // MARK: - Private Methods - Helpers
    
    private func updateDoneButtonState() {
        setDoneButton(enabled: shouldEnableDoneButton)
    }
    
    private func setDoneButton(enabled: Bool) {
        let color = enabled ? LayoutConstants.Button.backgroundColor : LayoutConstants.Button.disabledBackgroundColor
        let textColor = enabled ? LayoutConstants.Button.textColor : LayoutConstants.Button.disabledTextColor
        doneButton.isEnabled = enabled
        doneButton.backgroundColor = color
        doneButton.setTitleColor(textColor, for: .normal)
    }
    
    // MARK: - Private Methods - Intentions
    
    @objc
    private func textFieldEditingChanged(_ sender: UITextField) {
        updateDoneButtonState()
    }
    
    @objc
    private func doneButtonTapped() {
        guard let categoryTitle = textField.text else {
            assertionFailure("CategoryCreationViewController.doneButtonTapped: TextField.text is nil")
            return
        }
        let newCategory = TrackerCategory(id: UUID(), title: categoryTitle)
        delegate?.categoryCreationViewControllerDelegate(self, didCreateCategory: newCategory)
    }
}


// MARK: - UITextFieldDelegate
extension CategoryCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


// MARK: - LayoutConstants
extension CategoryCreationViewController {
    enum LayoutConstants {
        static let backgroundColor: UIColor = .ypWhite
        enum Title {
            static let font: UIFont = .systemFont(ofSize: 16, weight: .medium)
            static let textColor: UIColor = .ypBlack
            static let spacingToSuperviewTop: CGFloat = 27
        }
        enum TextField {
            static let topPadding: CGFloat = 38
            static let width: CGFloat = 343
            static let maxTextLength = 38
        }
        enum Button {
            static let backgroundColor: UIColor = .ypBlack
            static let disabledBackgroundColor: UIColor = .ypGray
            static let font: UIFont = .systemFont(ofSize: 16, weight: .medium)
            static let textColor: UIColor = .ypWhite
            static let disabledTextColor: UIColor = .white
            static let cornerRadius: CGFloat = 16
            static let spacingToSuperviewBottom: CGFloat = 16
            static let height: CGFloat = 60
            static let width: CGFloat = 335
        }
    }
}


// MARK: - Strings
extension CategoryCreationViewController {
    enum Strings {
        static let title = NSLocalizedString("categoryCreation.view_title", comment: "")
        static let doneButtonTitle = NSLocalizedString("categoryCreation.doneButton_title", comment: "")
        static let textFieldPlaceholderTitle = NSLocalizedString("categoryCreation.textField.placeholder_title", comment: "")
    }
}
