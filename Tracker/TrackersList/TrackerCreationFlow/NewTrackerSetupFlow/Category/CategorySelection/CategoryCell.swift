//
//  CategorySelectionCell.swift
//  Tracker
//
//  Created by Vladimir on 09.06.2025.
//

import UIKit


// MARK: - CategoryCell
final class CategoryCell: UITableViewCell {
    
    // MARK: - Internal Properties
    
    static let reuseID = "CategorySelectionCell"
    
    // MARK: - Private properties
    
    private let separatorView = UIView()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        layer.maskedCorners = []
        layer.masksToBounds = false
        selectedBackgroundView?.layer.maskedCorners = []
        selectedBackgroundView?.layer.masksToBounds = false
        setSeparator(hidden: false)
    }
    
    // MARK: - Internal Methods
    
    func configure(with cellModel: CategorySelectionCellModel) {
        textLabel?.text = cellModel.text
        accessoryType = cellModel.isSelected ? .checkmark : .none
        switch (cellModel.isFirst, cellModel.isLast) {
        case (true, true):
            setSeparator(hidden: true)
            layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
            selectedBackgroundView?.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
        case (true, false):
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            selectedBackgroundView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            setSeparator(hidden: false)
        case (false, true):
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            selectedBackgroundView?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            setSeparator(hidden: true)
        case (false, false):
            layer.maskedCorners = []
            selectedBackgroundView?.layer.maskedCorners = []
        }
    }
    
    // MARK: - Private Methods
    private func setUpCell() {
        backgroundColor = LayoutConstants.backgroundColor
        textLabel?.textColor = LayoutConstants.textColor
        textLabel?.font = LayoutConstants.textFont
        layer.cornerRadius = LayoutConstants.cornerRadius
        selectedBackgroundView?.layer.cornerRadius = LayoutConstants.cornerRadius
        
        contentView.addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = LayoutConstants.separatorColor
        NSLayoutConstraint.activate([
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: LayoutConstants.separatorHeight),
            separatorView.widthAnchor.constraint(equalToConstant: LayoutConstants.separatorWidth)
        ])
    }
    
    private func setSeparator(hidden: Bool) {
        separatorView.isHidden = hidden
    }
    
}


// MARK: - LayoutConstants
extension CategoryCell {
    enum LayoutConstants {
        static let cornerRadius: CGFloat = 16
        static let separatorColor: UIColor = .gray
        static let textFont: UIFont = .systemFont(ofSize: 17, weight: .regular)
        static let textColor: UIColor = .ypBlack
        static let backgroundColor: UIColor = .ypBackground
        static let separatorHeight: CGFloat = 0.5
        static let separatorWidth: CGFloat = 311
    }
}
