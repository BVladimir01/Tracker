//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Vladimir on 06.05.2025.
//

import UIKit


// MARK: - TrackerCollectionViewCellDelegate
protocol TrackerCollectionViewCellDelegate: AnyObject {
    func trackerCellDidTapRecord(cell: TrackerCollectionViewCell)
    func menuConfiguration(for cell: TrackerCollectionViewCell) -> UIContextMenuConfiguration?
}


// MARK: - TrackerCollectionViewCell
final class TrackerCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Internal Properties
    
    static let reuseID = "TrackerCell"
    
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    private(set) var trackerID: UUID?
    
    // MARK: - Private Properties
    
    private let trackerMainView = UIView()
    private let trackerRecordView = UIView()
    private let emojiLabel = UILabel()
    private let pinImageView = UIImageView(image: LayoutConstants.PinIcon.image)
    private let titleLabel = UILabel()
    private let recordLabel = UILabel()
    private let recordButton = UIButton()
    
    private var themeColor: UIColor = .red {
        didSet {
            trackerMainView.backgroundColor = themeColor
            if let image = recordButton.image(for: .normal) {
                recordButton.setImage(image.withTintColor(themeColor), for: .normal)
            }
        }
    }
    private var isCompleted: Bool = false {
        didSet {
            let newImage = UIImage(resource: isCompleted ? .minus : .plus).withTintColor(themeColor)
            recordButton.setImage(newImage, for: .normal)
        }
    }
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - LifeCycle
    
    override func prepareForReuse() {
        delegate = nil
        trackerID = nil
        emojiLabel.text = ""
        pinImageView.image = nil
        titleLabel.text = ""
        recordLabel.text = ""
    }
    
    // MARK: - Internal Methods
    
    func configure(with viewModel: TrackerCellModel) {
        titleLabel.text = viewModel.title
        emojiLabel.text = String(viewModel.emoji)
        themeColor = viewModel.color
        isCompleted = viewModel.isCompleted
        recordLabel.text = viewModel.recordText
        pinImageView.isHidden = !viewModel.isPinned
    }
    
    func setRecordButton(enabled: Bool) {
        recordButton.isEnabled = enabled
    }
    
    // MARK: - Private Methods - Setup
    
    private func setUpViews() {
        setUpTrackerMainView()
        setupTrackerRecordView()
    }
    
    private func setUpTrackerMainView() {
        trackerMainView.backgroundColor = themeColor
        trackerMainView.layer.cornerRadius = LayoutConstants.trackerMainViewCornerRadius
        trackerMainView.layer.masksToBounds = true
        setUpEmoji()
        setUpPin()
        setUpTitle()
        
        trackerMainView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(trackerMainView)
        NSLayoutConstraint.activate([
            trackerMainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerMainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerMainView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerMainView.heightAnchor.constraint(equalToConstant: LayoutConstants.trackerMainViewHeight)
        ])
        
        trackerMainView.addInteraction(UIContextMenuInteraction(delegate: self))
    }
    
    private func setUpEmoji() {
        emojiLabel.backgroundColor = LayoutConstants.Emoji.backgroundColor
        emojiLabel.layer.cornerRadius = LayoutConstants.Emoji.viewSize/2
        emojiLabel.layer.masksToBounds = true
        emojiLabel.text = "😀"
        emojiLabel.textAlignment = .center
        emojiLabel.font = LayoutConstants.Emoji.font
        
        trackerMainView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emojiLabel.widthAnchor.constraint(equalToConstant: LayoutConstants.Emoji.viewSize),
            emojiLabel.heightAnchor.constraint(equalToConstant: LayoutConstants.Emoji.viewSize),
            emojiLabel.leadingAnchor.constraint(equalTo: trackerMainView.leadingAnchor,
                                                constant: LayoutConstants.Emoji.lateralPadding),
            emojiLabel.topAnchor.constraint(equalTo: trackerMainView.topAnchor,
                                            constant: LayoutConstants.Emoji.lateralPadding)
        ])
    }
    
    private func setUpPin() {
        pinImageView.tintColor = LayoutConstants.PinIcon.color
        pinImageView.isHidden = true
        
        trackerMainView.addSubview(pinImageView)
        pinImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pinImageView.topAnchor.constraint(equalTo: trackerMainView.topAnchor,
                                              constant: LayoutConstants.PinIcon.verticalPadding),
            pinImageView.trailingAnchor.constraint(equalTo: trackerMainView.trailingAnchor,
                                                   constant: -LayoutConstants.PinIcon.lateralPadding),
        ])
    }
    
    private func setUpTitle() {
        titleLabel.textAlignment = .left
        titleLabel.text = "Title"
        titleLabel.textColor = .white
        titleLabel.font = LayoutConstants.Title.font
        titleLabel.numberOfLines = 2
        
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
    
    private func setupTrackerRecordView() {
        setUpRecordLabel()
        setupRecordButton()
        
        trackerRecordView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(trackerRecordView)
        NSLayoutConstraint.activate([
            trackerRecordView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerRecordView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerRecordView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            trackerRecordView.topAnchor.constraint(equalTo: trackerMainView.bottomAnchor)
        ])
    }
    
    private func setUpRecordLabel() {
        recordLabel.backgroundColor = .clear
        recordLabel.text = "n days"
        recordLabel.textAlignment = .left
        recordLabel.font = LayoutConstants.Record.font
        recordLabel.textColor = LayoutConstants.Record.textColor
        
        recordLabel.translatesAutoresizingMaskIntoConstraints = false
        trackerRecordView.addSubview(recordLabel)
        NSLayoutConstraint.activate([
            recordLabel.leadingAnchor.constraint(equalTo: trackerRecordView.leadingAnchor,
                                                 constant: LayoutConstants.Record.leftPadding),
            recordLabel.topAnchor.constraint(equalTo: trackerRecordView.topAnchor,
                                             constant: LayoutConstants.Record.topPadding),
            recordLabel.heightAnchor.constraint(equalToConstant: LayoutConstants.Record.height)
        ])
    }
    
    private func setupRecordButton() {
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        recordButton.setImage(UIImage(resource: .plus).withTintColor(themeColor), for: .normal)
        
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
    
    // MARK: - Private Methods - Intentions
    
    @objc
    private func recordButtonTapped() {
        delegate?.trackerCellDidTapRecord(cell: self)
    }
    
}


// MARK: - UIContextMenuInteractionDelegate
extension TrackerCollectionViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        delegate?.menuConfiguration(for: self)
    }
}


// MARK: - LayoutConstants
extension TrackerCollectionViewCell {
    private enum LayoutConstants {
        static let trackerMainViewCornerRadius: CGFloat = 16
        static let trackerMainViewHeight: CGFloat = 90
        enum Emoji {
            static let backgroundColor = UIColor.white.withAlphaComponent(0.3)
            static let viewSize: CGFloat = 24
            static let font: UIFont = .systemFont(ofSize: 16, weight: .medium)
            static let verticalPadding: CGFloat = 12
            static let lateralPadding: CGFloat = 12
        }
        enum Title {
            static let font: UIFont = .systemFont(ofSize: 12, weight: .medium)
            static let lateralPadding: CGFloat = 12
            static let bottomPadding: CGFloat = 12
        }
        enum Record {
            static let font: UIFont = .systemFont(ofSize: 12, weight: .medium)
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
        enum PinIcon {
            static let image = UIImage.pin
            static let color = UIColor.white
            static let width: CGFloat = 24
            static let height: CGFloat = 24
            static let verticalPadding: CGFloat = 18
            static let lateralPadding: CGFloat = 12
        }
    }
}
