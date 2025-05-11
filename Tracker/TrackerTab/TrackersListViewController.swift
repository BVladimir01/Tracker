//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Vladimir on 01.05.2025.
//

import UIKit


// MARK: - TrackersListViewController
final class TrackersListViewController: UIViewController, NewTrackerViewControllerDelegate {
    
    // MARK: - Internal Properties
    
    // isn't implicit unwrap conventional solution here?
    // if it is nil, the app SHOULD crash
    var dataStorage: TrackerDataSource!
    
    // MARK: - Private Properties

    private let collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: UICollectionViewFlowLayout())
    private let stubView = UIView()
    let datePicker = UIDatePicker()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Трекеры"
        view.backgroundColor = LayoutConstants.backgroundColor
        setUpStubView()
        setUpDoneButton()
        setUpDatePicker()
        setUpCollectionView()
    }
    
    // MARK: - Internal Methods
    
    func newTrackerViewControllerDidCreateTracker(_ vc: UIViewController) {
        collectionView.reloadData()
        vc.dismiss(animated: true)
    }
    
    // MARK: - Private Methods - Views Setup
    
    private func setUpStubView() {
        let stubImageView = UIImageView(image: .trackerStub)
        stubImageView.translatesAutoresizingMaskIntoConstraints = false
        stubView.addSubview(stubImageView)
        NSLayoutConstraint.activate([
            stubImageView.centerXAnchor.constraint(equalTo: stubView.centerXAnchor),
            stubImageView.heightAnchor.constraint(equalToConstant: LayoutConstants.Stub.imageHeight),
            stubImageView.widthAnchor.constraint(equalTo: stubImageView.heightAnchor, multiplier: LayoutConstants.Stub.imageAspectRatio),
            stubImageView.topAnchor.constraint(equalTo: stubView.topAnchor, constant: LayoutConstants.Stub.imageToStubViewTop),
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
    
    private func setUpDoneButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: .addTracker.withTintColor(LayoutConstants.addButtonColor, renderingMode: .alwaysOriginal), 
            style: .plain,
            target: self,
            action: #selector(addTrackerTapped))
    }
    
    private func setUpDatePicker() {
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
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
        collectionView.backgroundColor = LayoutConstants.backgroundColor
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Private Methods - Helpers
    
    private func trackerCellViewModel(from tracker: Tracker) -> TrackerCellViewModel {
        let recordText: String
        let daysEnding = ["дней", "день", "дня", "дня", "дня",
                          "дней", "дней", "дней", "дней", "дней"]
        let daysDone = dataStorage.daysDone(of: tracker.id)
        switch tracker.schedule {
        case .regular:
            let lastDigit = daysDone % 10
            recordText = "\(daysDone) \(daysEnding[lastDigit])"
        case .irregular:
            if daysDone == 0 {
                recordText = "Не выполнен"
            } else {
                recordText = "Выполнен"
            }
        }
        let isCompleted = dataStorage.isCompleted(trackerID: tracker.id, on: datePicker.date)
        return TrackerCellViewModel(title: tracker.title,
                                    color: UIColor.from(RGBColor: tracker.color),
                                    emoji: tracker.emoji,
                                    recordText: recordText, 
                                    isCompleted: isCompleted)
    }
    
    // MARK: - Private Methods - User Intentions

    @objc private func addTrackerTapped() {
        let creatorVC = NewTrackerViewController()
        creatorVC.delegate = self
        creatorVC.dataStorage = dataStorage
        present(creatorVC, animated: true)
    }
    
    @objc private func dateChanged() {
        // I do not think, new page should be shown
        // with batch updates, since there are too many changes.
        // Some categories may even disappear, since their trackers
        // should not be shown on this day. Thus reloading whole view
        collectionView.reloadData()
        if numberOfSections(in: collectionView) == 0 {
            collectionView.isHidden = true
        } else {
            collectionView.isHidden = false
        }
    }
    
}


// MARK: - UICollectionViewDataSource
extension TrackersListViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        dataStorage.trackerCategories(on: datePicker.date).count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataStorage.trackerCategories(on: datePicker.date)[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.reuseID, for: indexPath) as? TrackerCollectionViewCell else {
            assertionFailure("TrackerViewController.collectionView: Failed to dequeue or typecast cell")
            return UICollectionViewCell()
        }
        let categories = dataStorage.trackerCategories(on: datePicker.date)
        let trackerToShow = categories[indexPath.section].trackers[indexPath.item]
        cell.configure(with: trackerCellViewModel(from: trackerToShow))
        cell.set(trackerID: trackerToShow.id)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CategoryTitleView.reuseID, for: indexPath) as? CategoryTitleView else {
            assertionFailure("TrackerViewController.collectionView: Failed to dequeue supplementary view")
            return   UICollectionReusableView()
        }
        let categories = dataStorage.trackerCategories(on: datePicker.date)
        view.changeTitleText(categories[indexPath.section].title)
        return view
    }
    
}


// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersListViewController: UICollectionViewDelegateFlowLayout {
    
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


// MARK: - TrackerCollectionViewCellDelegate
extension TrackersListViewController: TrackerCollectionViewCellDelegate {
    func trackerCellDidTapRecord(cell: TrackerCollectionViewCell) {
        guard let trackerID = cell.trackerID else {
            assertionFailure("TrackerViewController.trackerCellDidTapRecord: Failed to get tracker id of the cell")
            return
        }
        guard let indexPath = collectionView.indexPath(for: cell) else {
            assertionFailure("TrackerViewController.trackerCellDidTapRecord: Failed to get indexPath of the cell")
            return
        }
        let date = datePicker.date
        if dataStorage.isCompleted(trackerID: trackerID, on: date) {
            dataStorage.removeRecord(for: trackerID, on: date)
        } else {
            dataStorage.addRecord(for: trackerID, on: date)
        }
        collectionView.reloadItems(at: [indexPath])
    }
}


// MARK: - LayoutConstants
extension TrackersListViewController {
    private enum LayoutConstants {
        static let backgroundColor: UIColor = .ypWhite
        static let addButtonColor: UIColor = .ypBlack
        enum Stub {
            static let imageHeight: CGFloat = 80
            static let imageAspectRatio: CGFloat = 1
            static let imageToStubViewTop: CGFloat = 220
            
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
