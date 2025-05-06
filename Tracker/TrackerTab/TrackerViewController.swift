//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Vladimir on 01.05.2025.
//

import UIKit


// MARK: - TrackerViewController
final class TrackerViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private var trackerCategories: [TrackerCategory] = [TrackerCategory(title: "TrackerCategoryTitle",
                                                                        trackers: [Tracker(id: UUID(),
                                                                                           title: "TrackerTitle",
                                                                                           color: RGBColor(red: 1, green: 1, blue: 1),
                                                                                           emoji: "😀",
                                                                                           schedule: .regular(Set<Weekday>([.friday, .monday])))])]
    private var completedTrackers: [TrackerRecord] = []

    private let collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: UICollectionViewFlowLayout())
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Трекеры"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .addTracker.withTintColor(.ypBlack, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(addTrackerTapped))
        setUpStub()
        setUpDatePicker()
    }
    
    // MARK: - Private Methods - View Configuration
    
    private func setUpStub() {
        let stubImageView = UIImageView(image: .trackerStub)
        stubImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stubImageView)
        NSLayoutConstraint.activate([
            stubImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImageView.heightAnchor.constraint(equalToConstant: LayoutConstants.Stub.imageHeight),
            stubImageView.widthAnchor.constraint(equalTo: stubImageView.heightAnchor, multiplier: LayoutConstants.Stub.imageAspectRatio),
            stubImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: LayoutConstants.Stub.imageTopToSuperViewTop),
            stubImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -LayoutConstants.Stub.imageBottomSuperViewBottom)
        ])
        
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: LayoutConstants.Stub.labelFontSize, weight: LayoutConstants.Stub.labelFontWeight)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: LayoutConstants.Stub.labelTopToStubImageBottom)
        ])
    }
    
    private func setUpDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func setUpCollectionView() {
        collectionView
    }
    
    // MARK: - Private Methods - User Intentions

    @objc private func addTrackerTapped() {
        // TODO: Implement tracker addition
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let date = sender.date
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = formatter.string(from: date)
        print("today is \(formattedDate)")
    }
    
}


// MARK: - LayoutConstants
extension TrackerViewController {
    private enum LayoutConstants {
        enum Stub {
            static let imageHeight: CGFloat = 80
            static let imageAspectRatio: CGFloat = 1
            static let imageTopToSuperViewTop: CGFloat = 402
            static let imageBottomSuperViewBottom: CGFloat = 330
            
            static let labelFontSize: CGFloat = 12
            static let labelFontWeight: UIFont.Weight = .medium
            static let labelTopToStubImageBottom: CGFloat = 8
        }
    }
}


extension TrackerViewController: UICollectionViewDataSource {
    
}


extension TrackerViewController: UICollectionViewDelegate {
    
    
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    
}
