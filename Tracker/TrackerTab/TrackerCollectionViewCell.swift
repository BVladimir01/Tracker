//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Vladimir on 06.05.2025.
//

import UIKit

class TrackerCollectionViewCell: UICollectionViewCell {
    
    static let reuseId = "TrackerCell"
    
    private let trackerMainView = UIView()
    private let trackerRecordView = UIView()
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let recordLabel = UILabel()
    private let recordButton = UIButton()
    
    private var themeColor: UIColor = .red
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUp() {
        setUpTrackerMainView()
        trackerMainView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(trackerMainView)
        NSLayoutConstraint.activate([
            trackerMainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerMainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerMainView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerMainView.heightAnchor.constraint(equalToConstant: LayoutConstants.trackerMainViewHeight)
        ])
        
        setupTrackerRecordView()
        trackerRecordView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(trackerRecordView)
        NSLayoutConstraint.activate([
            trackerRecordView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerRecordView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerRecordView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            trackerRecordView.topAnchor.constraint(equalTo: trackerMainView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([contentView.widthAnchor.constraint(equalToConstant: LayoutConstants.contentViewWidth)])
    }
    
    private func setUpTrackerMainView() {
        trackerMainView.backgroundColor = themeColor
        trackerMainView.layer.cornerRadius = LayoutConstants.trackerMainViewCornerRadius
        trackerMainView.layer.masksToBounds = true
        
        setUpEmoji()
        trackerMainView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emojiLabel.widthAnchor.constraint(equalToConstant: LayoutConstants.Emoji.viewSize),
            emojiLabel.heightAnchor.constraint(equalToConstant: LayoutConstants.Emoji.viewSize),
            emojiLabel.leadingAnchor.constraint(equalTo: trackerMainView.leadingAnchor,
                                                constant: LayoutConstants.Emoji.leftPadding),
            emojiLabel.topAnchor.constraint(equalTo: trackerMainView.topAnchor,
                                            constant: LayoutConstants.Emoji.leftPadding)
        ])
        
        setUpTitle()
        trackerMainView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: trackerMainView.leadingAnchor,
                                                constant: LayoutConstants.Title.lateralPadding),
            titleLabel.trailingAnchor.constraint(equalTo: trackerMainView.trailingAnchor,
                                                 constant: -LayoutConstants.Title.lateralPadding),
            titleLabel.bottomAnchor.constraint(equalTo: trackerMainView.bottomAnchor,
                                               constant: -LayoutConstants.Title.bottomPadding),
            titleLabel.centerXAnchor.constraint(equalTo: trackerMainView.centerXAnchor)
        ])
    }
    
    private func setUpEmoji() {
        emojiLabel.backgroundColor = LayoutConstants.Emoji.backgroundColor
        emojiLabel.layer.cornerRadius = LayoutConstants.Emoji.viewSize/2
        emojiLabel.layer.masksToBounds = true
        emojiLabel.text = "😀"
        emojiLabel.textAlignment = .center
        emojiLabel.font = UIFont.systemFont(ofSize: LayoutConstants.Emoji.fontSize,
                                            weight: LayoutConstants.Emoji.fontWeight)
    }
    
    private func setUpTitle() {
        titleLabel.textAlignment = .left
        titleLabel.text = "Title"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: LayoutConstants.Title.fontSize,
                                            weight: LayoutConstants.Title.fontWeight)
        titleLabel.numberOfLines = 0
    }
    
    private func setupTrackerRecordView() {
        setUpRecordLabel()
        recordLabel.translatesAutoresizingMaskIntoConstraints = false
        trackerRecordView.addSubview(recordLabel)
        NSLayoutConstraint.activate([
            recordLabel.leadingAnchor.constraint(equalTo: trackerRecordView.leadingAnchor,
                                                 constant: LayoutConstants.Record.leftPadding),
            recordLabel.topAnchor.constraint(equalTo: trackerRecordView.topAnchor,
                                             constant: LayoutConstants.Record.topPadding),
            recordLabel.heightAnchor.constraint(equalToConstant: LayoutConstants.Record.height)
        ])
        
        setupRecordButton()
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        trackerRecordView.addSubview(recordButton)
        NSLayoutConstraint.activate([
            recordButton.topAnchor.constraint(equalTo: trackerRecordView.topAnchor,
                                              constant: LayoutConstants.Button.topPadding),
            recordButton.trailingAnchor.constraint(equalTo: trackerRecordView.trailingAnchor,
                                                   constant: -LayoutConstants.Button.rightPadding),
            recordButton.widthAnchor.constraint(equalToConstant: LayoutConstants.Button.width),
            recordButton.heightAnchor.constraint(equalToConstant: LayoutConstants.Button.height)
        ])
    }
    
    private func setUpRecordLabel() {
        recordLabel.backgroundColor = .clear
        recordLabel.text = "n days"
        recordLabel.textAlignment = .left
        recordLabel.font = UIFont.systemFont(ofSize: LayoutConstants.Record.fontSize,
                                            weight: LayoutConstants.Record.fontWeight)
        recordLabel.textColor = LayoutConstants.Record.textColor
    }
    
    private func setupRecordButton() {
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        recordButton.setImage(UIImage(resource: .plus).withTintColor(themeColor), for: .normal)
    }
    
    @objc
    private func recordButtonTapped() {
        // TODO: - Implement button tap
    }
}


extension TrackerCollectionViewCell {
    private enum LayoutConstants {
        static let trackerMainViewCornerRadius: CGFloat = 16
        static let trackerMainViewHeight: CGFloat = 90
        static let contentViewWidth: CGFloat = 167
        enum Emoji {
            static let backgroundColor = UIColor.white.withAlphaComponent(0.3)
            static let viewSize: CGFloat = 24
            static let fontSize: CGFloat = 16
            static let fontWeight: UIFont.Weight = .medium
            static let topPadding: CGFloat = 12
            static let leftPadding: CGFloat = 12
        }
        enum Title {
            static let fontSize: CGFloat = 12
            static let fontWeight: UIFont.Weight = .medium
            static let lateralPadding: CGFloat = 12
            static let bottomPadding: CGFloat = 12
        }
        enum Record {
            static let fontSize: CGFloat = 12
            static let fontWeight: UIFont.Weight = .medium
            static let leftPadding: CGFloat = 12
            static let topPadding: CGFloat = 16
            static let height: CGFloat = 18
            static let textColor: UIColor = .ypBlack
        }
        enum Button {
            static let width: CGFloat = 44
            static let height: CGFloat = 44
            static let topPadding: CGFloat = -2
            static let rightPadding: CGFloat = 2
        }
    }
}
