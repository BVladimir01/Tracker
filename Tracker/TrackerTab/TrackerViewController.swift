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
    
    private static let testTracker1 = Tracker(id: UUID(),
                                      title: "TrackerTitle",
                                              color: UIColor.ypColorSelection1.rgbColor ?? RGBColor(red: 1, green: 0, blue: 0),
                                      emoji: "😀",
                                      schedule: .regular(Set<Weekday>([.friday, .monday])))
    private static let testTracker2 = Tracker(id: UUID(),
                                      title: "TrackerTitle2",
                                              color: UIColor.ypColorSelection2.rgbColor ?? RGBColor(red: 0, green: 1, blue: 0),
                                      emoji: "🥹",
                                      schedule: .regular(Set<Weekday>([.friday, .monday])))
    private static let testTracker3 = Tracker(id: UUID(),
                                      title: "TrackerTitle3",
                                              color: UIColor.ypColorSelection3.rgbColor ?? RGBColor(red: 0, green: 0, blue: 1),
                                      emoji: "🥹",
                                      schedule: .regular(Set<Weekday>([.friday, .monday])))
    
    private var trackerCategories: [TrackerCategory] = [
        TrackerCategory(title: "TrackerCategoryTitle1",
                        trackers: [testTracker1, testTracker2, testTracker3]),
        TrackerCategory(title: "TrackerCategoryTitle2",
                        trackers: [testTracker3, testTracker1, testTracker2]),
        TrackerCategory(title: "TrackerCategoryTitle3",
                        trackers: [testTracker2, testTracker3, testTracker1])
    ]
    
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
        setUpCollectionView()
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
//            stubImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -LayoutConstants.Stub.imageBottomSuperViewBottom)
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
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.reuseId)
        collectionView.register(CategoryTitleView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: CategoryTitleView.reuseId)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .ypWhite
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
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


// MARK: - UICollectionViewDataSource
extension TrackerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        trackerCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        trackerCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.reuseId, for: indexPath) as? TrackerCollectionViewCell else {
            assertionFailure("TrackerViewController.collectionView: Failed to dequeue cell")
            return UICollectionViewCell()
        }
        cell.configure(tracker: trackerCategories[indexPath.section].trackers[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CategoryTitleView.reuseId, for: indexPath) as? CategoryTitleView else {
            assertionFailure("TrackerViewController.collectionView: Failed to dequeue supplementary view")
            return   UICollectionReusableView()
        }
        view.changeTitleText(trackerCategories[indexPath.section].title)
        return view
    }
    
}


// MARK: - UICollectionViewDelegate
extension TrackerViewController: UICollectionViewDelegate {
    
    
}


// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        LayoutConstants.CollectionView.itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        LayoutConstants.CollectionView.interItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        LayoutConstants.CollectionView.lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        LayoutConstants.CollectionView.insets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let view = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        let width = collectionView.frame.width - 2*LayoutConstants.CollectionView.headerLateralPadding
        return view.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
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
        enum CollectionView {
            static let itemSize = CGSize(width: 167, height: 148)
            static let interItemSpacing: CGFloat = 9
            static let lineSpacing: CGFloat = 0
            static let insets = UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
            static let headerLateralPadding: CGFloat = 28
        }
    }
}
