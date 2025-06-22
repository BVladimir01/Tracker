//
//  MyTextFieldView.swift
//  Tracker
//
//  Created by Vladimir on 22.06.2025.
//

import UIKit


final class MyTextFieldView: UIView {
    
    // MARK: - Internal Properties
    
    var onTextChange: Binding<String>?
    var delegate: UITextFieldDelegate? {
        didSet {
            textField.delegate = delegate
        }
    }
    var placeholder: String? {
        didSet {
            textField.placeholder = placeholder
        }
    }
    
    var text: String? {
        textField.text
    }
    
    // MARK: - Private Properties
    
    private let textField = UITextField()
    private let xmarkButton = UIButton(type: .system)
    private let warning = UILabel()
    private var bottomConstraint: NSLayoutConstraint?
    
    private var shouldDisplayWarning: Bool {
        (textField.text?.count ?? 0) > 38
    }
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        setUpTextField()
        setUpWarning()
        addSubviewsAndConstraints()
        updateXMarkButtonState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    // MARK: - Lifecycle
    
    
    // MARK: - Private Methods
    
    private func setUpTextField() {
        textField.placeholder = placeholder
        textField.borderStyle = .none
        textField.layer.cornerRadius = LayoutConstants.TextField.cornerRadius
        textField.layer.masksToBounds = true
        textField.textColor = LayoutConstants.TextField.textColor
        textField.backgroundColor = LayoutConstants.TextField.backgroundColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(onEditingChange), for: .editingChanged)
        
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
        
        xmarkButton.setImage(LayoutConstants.XMark.xmarkImage, for: .normal)
        xmarkButton.tintColor = LayoutConstants.XMark.xmarkColor
        xmarkButton.addTarget(self, action: #selector(xmarkCircleTapped), for: .touchUpInside)
        xmarkButton.translatesAutoresizingMaskIntoConstraints = false
        textField.addSubview(xmarkButton)
        
    }
    
    private func setUpWarning() {
        warning.text = Strings.warning
        warning.font = LayoutConstants.Warning.font
        warning.textColor = LayoutConstants.Warning.textColor
        warning.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addSubviewsAndConstraints() {
        addSubview(textField)
        NSLayoutConstraint.activate([
            xmarkButton.widthAnchor.constraint(equalToConstant: LayoutConstants.XMark.xmarkButtonSize),
            xmarkButton.heightAnchor.constraint(equalToConstant: LayoutConstants.XMark.xmarkButtonSize),
            xmarkButton.trailingAnchor.constraint(equalTo: textField.trailingAnchor,
                                                  constant: LayoutConstants.XMark.xmarkRightPadding),
            xmarkButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: LayoutConstants.TextField.height),
            
        ])
        bottomConstraint = textField.bottomAnchor.constraint(equalTo: bottomAnchor)
        if let bottomConstraint {
            NSLayoutConstraint.activate([bottomConstraint])
        }
    }
    
    // MARK: - Private Methods - Helpers
    
    private func updateXMarkButtonState() {
        if let isHidden = textField.text?.isEmpty {
            xmarkButton.isHidden = isHidden
        } else {
            xmarkButton.isHidden = true
        }
    }
    
    private func updateWarningState() {
        if shouldDisplayWarning && !subviews.contains(warning){
            addSubview(warning)
            warning.translatesAutoresizingMaskIntoConstraints = false
            if let bottomConstraint {
                NSLayoutConstraint.deactivate([
                    bottomConstraint
                ])
            }
            NSLayoutConstraint.activate([
                warning.topAnchor.constraint(equalTo: textField.bottomAnchor,
                                             constant: LayoutConstants.Warning.topSpacing),
                warning.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                constant: -LayoutConstants.Warning.bottomSpacing),
                warning.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
                warning.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
                warning.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
        }
        if !shouldDisplayWarning && subviews.contains(warning)
        {
            warning.removeFromSuperview()
            if let bottomConstraint {
                NSLayoutConstraint.activate([
                    bottomConstraint
                ])
            }
        }
    }
    
    // MARK: - Private Methods - Intentions
    
    @objc
    private func onEditingChange() {
        guard let text = textField.text else { return }
        updateWarningState()
        updateXMarkButtonState()
        onTextChange?(text)
    }
    
    @objc
    private func xmarkCircleTapped() {
        textField.text = nil
        onEditingChange()
    }

}

// MARK: - LayoutConstants
extension MyTextFieldView {
    enum LayoutConstants {
        enum TextField {
            static let backgroundColor: UIColor = .ypBackground
            static let font: UIFont = .systemFont(ofSize: 17, weight: .regular)
            static let textColor: UIColor = .ypBlack
            static let cornerRadius: CGFloat = 16
            static let height: CGFloat = 75
            static let innerLeftPadding: CGFloat = 16
            static let innerRightPadding: CGFloat = 41
        }
        enum XMark {
            static let xmarkImage = UIImage(systemName: "xmark.circle.fill")
            static let xmarkColor: UIColor = .ypGray
            static let xmarkButtonSize: CGFloat = 44
            static let xmarkRightPadding: CGFloat = -1.5
        }
        enum Warning {
            static let topSpacing: CGFloat = 8
            static let bottomSpacing: CGFloat = 8
            static let textColor: UIColor = .ypRed
            static let font: UIFont = .systemFont(ofSize: 17, weight: .regular)
        }
    }
}


// MARK: - Strings
extension MyTextFieldView {
    enum Strings {
        static let warning = NSLocalizedString("textField.warning", comment: "")
    }
}
