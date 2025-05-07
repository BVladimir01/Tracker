//
//  CategoryTitleView.swift
//  Tracker
//
//  Created by Vladimir on 07.05.2025.
//

import UIKit


// MARK: - CategoryTitleView
class CategoryTitleView: UICollectionReusableView {
    
    // MARK: - Internal Properties
    
    static let reuseId = "CategoryTitleView"
    
    // MARK: - Private Properties
    
    private let titleLabel = UILabel()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLabel()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: - Private Methods
    
    private func setUpLabel() {
        titleLabel.text = "CategoryTitle"
        titleLabel.textAlignment = LayoutConstants.textAlignment
        titleLabel.font = LayoutConstants.font
        titleLabel.textColor = LayoutConstants.textColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: LayoutConstants.lateralPadding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -LayoutConstants.lateralPadding)
        ])
    }
    
    // MARK: - Internal Methods
    
    func changeTitleText(_ text: String) {
        titleLabel.text = text
    }
    
}


// MARK: - LayoutConstants
extension CategoryTitleView {
    enum LayoutConstants {
        static let font = UIFont.systemFont(ofSize: 19, weight: .bold)
        static let textColor: UIColor = .ypBlack
        static let textAlignment: NSTextAlignment = .left
        static let lateralPadding: CGFloat = 28
    }
}
