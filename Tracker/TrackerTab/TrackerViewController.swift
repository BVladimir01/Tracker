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
    
    private let trackerDataStorage: TrackerDataSource = TrackerDataStore.shared

    private let collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: UICollectionViewFlowLayout())
    private let stubView = UIView()
    let datePicker = UIDatePicker()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Трекеры"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .addTracker.withTintColor(.ypBlack, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(addTrackerTapped))
        setUpStubView()
        setUpDatePicker()
        setUpCollectionView()
//        stubView.layer.zPosition = 1
    }
    
    // MARK: - Private Methods - View Configuration
    
    private func setUpStubView() {
        let stubImageView = UIImageView(image: .trackerStub)
        stubImageView.translatesAutoresizingMaskIntoConstraints = false
        stubView.addSubview(stubImageView)
        NSLayoutConstraint.activate([
            stubImageView.centerXAnchor.constraint(equalTo: stubView.centerXAnchor),
            stubImageView.heightAnchor.constraint(equalToConstant: LayoutConstants.Stub.imageHeight),
            stubImageView.widthAnchor.constraint(equalTo: stubImageView.heightAnchor, multiplier: LayoutConstants.Stub.imageAspectRatio),
            stubImageView.topAnchor.constraint(equalTo: stubView.topAnchor, constant: LayoutConstants.Stub.imageTopPadding),
        ])
        
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = LayoutConstants.Stub.labelFont
        label.textColor = LayoutConstants.Stub.textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        stubView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: stubView.centerXAnchor),
            label.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: LayoutConstants.Stub.labelTopToStubImageBottom)
        ])
        
        stubView.backgroundColor = .ypWhite
        stubView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stubView)
        NSLayoutConstraint.activate([
            stubView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stubView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stubView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stubView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setUpDatePicker() {
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func setUpCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.reuseID)
        collectionView.register(CategoryTitleView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: CategoryTitleView.reuseID)
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
        // TODO: Process change of date
    }
    
}


// MARK: - UICollectionViewDataSource
extension TrackerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        trackerDataStorage.trackerCategories(on: datePicker.date).count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        trackerDataStorage.trackerCategories(on: datePicker.date)[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.reuseID, for: indexPath) as? TrackerCollectionViewCell else {
            assertionFailure("TrackerViewController.collectionView: Failed to dequeue cell")
            return UICollectionViewCell()
        }
        let categories = trackerDataStorage.trackerCategories(on: datePicker.date)
        let trackerToShow = categories[indexPath.section].trackers[indexPath.item]
        cell.configure(tracker: trackerToShow)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CategoryTitleView.reuseID, for: indexPath) as? CategoryTitleView else {
            assertionFailure("TrackerViewController.collectionView: Failed to dequeue supplementary view")
            return   UICollectionReusableView()
        }
        let categories = trackerDataStorage.trackerCategories(on: datePicker.date)
        view.changeTitleText(categories[indexPath.section].title)
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


// MARK: -
extension TrackerViewController: TrackerCollectionViewCellDelegate {
    func trackerCellDidTapRecord(cell: TrackerCollectionViewCell) {
        // TODO: process cell tap
    }
}


// MARK: - LayoutConstants
extension TrackerViewController {
    private enum LayoutConstants {
        enum Stub {
            static let imageHeight: CGFloat = 80
            static let imageAspectRatio: CGFloat = 1
            static let imageTopPadding: CGFloat = 220
            
            static let labelFont: UIFont = .systemFont(ofSize: 12, weight: .medium)
            static let textColor: UIColor = .ypBlack
            static let labelTopToStubImageBottom: CGFloat = 8
            
            static let backgroundColor: UIColor = .ypWhite
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
