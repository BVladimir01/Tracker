//
//  CategoryEditorViewController.swift
//  Tracker
//
//  Created by Vladimir on 21.06.2025.
//

import UIKit


// MARK: CategoryEditorViewControllerDelegate
protocol CategoryEditorViewControllerDelegate: AnyObject {
    func categoryEditorViewController(_ vc: UIViewController, didChange oldCategory: TrackerCategory, to newCategory: TrackerCategory)
}


// MARK: - CategoryEditorViewController
final class CategoryEditorViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private weak var delegate: CategoryEditorViewControllerDelegate?
    
    private let titleLabel = UILabel()
    private let textField = TrackerTextFieldView()
    private let doneButton = UIButton(type: .system)
    private let oldCategory: TrackerCategory
    
    private var shouldEnableDoneButton: Bool {
        if let text = textField.text, text.count <= LayoutConstants.TextField.maxTextLength {
            !text.isEmpty
        } else {
            false
        }
    }
    
    // MARK: Initializers
    
    init(oldCategory: TrackerCategory, delegate: CategoryEditorViewControllerDelegate) {
        self.oldCategory = oldCategory
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
        initializeViewWithOldData()
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
    
    private func initializeViewWithOldData() {
        textField.text = oldCategory.title
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
            assertionFailure("CategoryEditorViewController.doneButtonTapped: TextField.text is nil")
            return
        }
        let newCategory = TrackerCategory(id: oldCategory.id, title: categoryTitle)
        delegate?.categoryEditorViewController(self, didChange: oldCategory, to: newCategory)
    }
}


// MARK: - UITextFieldDelegate
extension CategoryEditorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


// MARK: - LayoutConstants
extension CategoryEditorViewController {
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
extension CategoryEditorViewController {
    enum Strings {
        static let title = NSLocalizedString("CategoryEditorViewController.view_title", comment: "")
        static let doneButtonTitle = NSLocalizedString("CategoryEditorViewController.doneButton_title", comment: "")
        static let textFieldPlaceholderTitle = NSLocalizedString("CategoryEditorViewController.textField.placeholder_title", comment: "")
    }
}
