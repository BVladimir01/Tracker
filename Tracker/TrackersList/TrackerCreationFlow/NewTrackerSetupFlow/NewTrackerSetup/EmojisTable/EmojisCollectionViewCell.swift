//
//  EmojisCollectionViewCell.swift
//  Tracker
//
//  Created by Vladimir on 28.05.2025.
//

import UIKit


final class EmojisCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Internal Properties
    var emoji = "" {
        didSet {
            emojiLabel.text = emoji
        }
    }
    override var isSelected: Bool {
        didSet {
            updateHighlighting()
        }
    }
    
    static let reuseID = "emojiCell"
    
    // MARK: - Private Properties
    
    private let emojiLabel = UILabel()
    private let highlighting = UIView()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = LayoutConstants.backgroundColor
        setUpHighlighting()
        setUpEmoji()
        contentView.sendSubviewToBack(highlighting)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        emoji = ""
        isSelected = false
    }
    
    // MARK: - Private Methods
    
    private func setUpEmoji() {
        emojiLabel.font = LayoutConstants.font
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func setUpHighlighting() {
        highlighting.backgroundColor = .clear
        highlighting.layer.cornerRadius = LayoutConstants.highlightingCorderRadius
        highlighting.layer.masksToBounds = true
        highlighting.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(highlighting)
        NSLayoutConstraint.activate([
            highlighting.topAnchor.constraint(equalTo: contentView.topAnchor),
            highlighting.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            highlighting.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            highlighting.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func updateHighlighting() {
        if isSelected {
            highlighting.backgroundColor = LayoutConstants.highlightingColor
        } else {
            highlighting.backgroundColor = .clear
        }
    }
    
}


// MARK: - LayoutConstants
extension EmojisCollectionViewCell {
    private enum LayoutConstants {
        static let backgroundColor: UIColor = .ypWhite
        static let font: UIFont = .systemFont(ofSize: 32, weight: .bold)
        static let highlightingColor: UIColor = .ypLightGray
        static let highlightingCorderRadius: CGFloat = 16
    }
}
