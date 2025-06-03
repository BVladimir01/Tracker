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
    
    private var categoryStore: CategoryStore
    private weak var delegate: CategoryCreationViewControllerDelegate?
    
    private let textField = UITextField()
    private let doneButton = UIButton(type: .system)
    
    private var shouldEnableDoneButton: Bool {
        if let text = textField.text {
            !text.isEmpty
        } else {
            false
        }
    }
    
    // MARK: Initializers
    
    init(categoryStore: CategoryStore, delegate: CategoryCreationViewControllerDelegate) {
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
        let title = UILabel()
        title.text = "Новая Категория"
        title.font = LayoutConstants.Title.font
        title.textColor = LayoutConstants.Title.textColor
        title.textAlignment = .center
        
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                       constant: LayoutConstants.Title.spacingToSuperviewTop)
        ])
    }
    
    private func setUpTextField() {
        textField.placeholder = LayoutConstants.TextField.placeHolder
        textField.borderStyle = .none
        textField.layer.cornerRadius = LayoutConstants.TextField.cornerRadius
        textField.layer.masksToBounds = true
        textField.textColor = LayoutConstants.TextField.textColor
        textField.backgroundColor = LayoutConstants.TextField.backgroundColor
        textField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        textField.delegate = self
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0,
                                                   width: LayoutConstants.TextField.innerLeftPadding,
                                                   height: LayoutConstants.TextField.height))
        leftPaddingView.alpha = 0
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0,
                                                   width: LayoutConstants.TextField.innerRightPadding,
                                                   height: LayoutConstants.TextField.height))
        rightPaddingView.alpha = 0
        textField.rightView = rightPaddingView
        textField.rightViewMode = .always
        
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                               constant: LayoutConstants.TextField.spacingToSuperviewTop),
            textField.widthAnchor.constraint(equalToConstant: LayoutConstants.TextField.width),
            textField.heightAnchor.constraint(equalToConstant: LayoutConstants.TextField.height)
        ])
    }
    
    private func setUpDoneButton() {
        doneButton.setTitle("Готово", for: .normal)
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
    }
    
    // MARK: - Private Methods - Helpers
    
    private func updateDoneButtonState() {
        setDoneButton(enabled: shouldEnableDoneButton)
    }
    
    private func setDoneButton(enabled: Bool) {
        let color = enabled ? LayoutConstants.Button.backgroundColor : LayoutConstants.Button.disabledBackgroundColor
        doneButton.isEnabled = enabled
        doneButton.backgroundColor = color
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
        do {
            delegate?.categoryCreationViewControllerDelegate(self, didCreateCategory: newCategory)
        } catch {
            assertionFailure("CategoryCreationViewController.doneButtonTapped: error \(error)")
        }
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
            static let placeHolder = "Введите название категории"
            static let backgroundColor: UIColor = .ypBackground
            static let font: UIFont = .systemFont(ofSize: 17, weight: .regular)
            static let textColor: UIColor = .ypBlack
            static let cornerRadius: CGFloat = 16
            static let spacingToSuperviewTop: CGFloat = 87
            static let width: CGFloat = 343
            static let height: CGFloat = 75
            static let innerLeftPadding: CGFloat = 16
            static let innerRightPadding: CGFloat = 41
        }
        enum Button {
            static let backgroundColor: UIColor = .ypBlack
            static let disabledBackgroundColor: UIColor = .ypGray
            static let font: UIFont = .systemFont(ofSize: 16, weight: .medium)
            static let textColor: UIColor = .ypWhite
            static let cornerRadius: CGFloat = 16
            static let spacingToSuperviewBottom: CGFloat = 16
            static let height: CGFloat = 60
            static let width: CGFloat = 335
        }
    }
}
