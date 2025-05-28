//
//  ColorsCollectionViewCell.swift
//  Tracker
//
//  Created by Vladimir on 28.05.2025.
//

import UIKit


final class ColorsCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Internal Properties
    var color: UIColor = .clear {
        didSet {
            colorTile.backgroundColor = color
        }
    }
    override var isSelected: Bool {
        didSet {
            updateHighlighting()
        }
    }
    
    static let reuseID = "colorCell"
    
    // MARK: - Private Properties
    
    private let colorTile = UILabel()
    private let highlighting = UIView()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = LayoutConstants.backgroundColor
        setUpHighlighting()
        setUpColorTile()
        contentView.sendSubviewToBack(highlighting)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        color = .clear
        isSelected = false
    }
    
    // MARK: - Private Methods
    
    private func setUpColorTile() {
        colorTile.backgroundColor = color
        colorTile.layer.cornerRadius = LayoutConstants.tileCornerRadius
        colorTile.layer.masksToBounds = true
        colorTile.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorTile)
        NSLayoutConstraint.activate([
            colorTile.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorTile.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorTile.widthAnchor.constraint(equalToConstant: LayoutConstants.tileSize),
            colorTile.heightAnchor.constraint(equalToConstant: LayoutConstants.tileSize)
        ])
    }
    
    private func setUpHighlighting() {
        highlighting.backgroundColor = .clear
        highlighting.layer.cornerRadius = LayoutConstants.tileCornerRadius
        highlighting.layer.masksToBounds = true
        highlighting.layer.borderWidth = LayoutConstants.highlightingBorderWidth
        highlighting.layer.borderColor = UIColor.clear.cgColor
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
        let color = isSelected ? color.withAlphaComponent(LayoutConstants.highlightingOpacity) : .clear
        highlighting.layer.borderColor = color.cgColor
    }
    
}


// MARK: - LayoutConstants
extension ColorsCollectionViewCell {
    private enum LayoutConstants {
        static let backgroundColor: UIColor = .ypWhite
        static let highlightingBorderWidth: CGFloat = 3
        static let highlightingOpacity: CGFloat = 0.3
        static let tileCornerRadius: CGFloat = 8
        static let tileSize: CGFloat = 40
    }
}
