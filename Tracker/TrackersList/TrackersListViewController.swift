//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Vladimir on 01.05.2025.
//

import UIKit


// MARK: - TrackersListViewController
final class TrackersListViewController: UIViewController, NewTrackerViewControllerDelegate {
    
    // MARK: - Private Properties

    private let collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: UICollectionViewFlowLayout())
    private let stubView = UIView()
    private let datePicker = UIDatePicker()
    
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    
    private var shouldShowStubView: Bool {
        trackerStore.numberOfSections == 0
    }
    
    private var selectedDate: Date {
        datePicker.date
    }
    
    // MARK: - Lifecycle
    
    init(trackerDataStores: TrackerDataStores) {
        self.trackerStore = trackerDataStores.trackerStore
        self.categoryStore = trackerDataStores.trackerCategoryStore
        self.recordStore = trackerDataStores.trackerRecordStore
        super.init(nibName: nil, bundle: nil)
        trackerStore.delegate = self
        do {
            try trackerStore.set(date: datePicker.date)
        } catch {
            assertionFailure("TrackersListViewController.init: error \(error)")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Трекеры"
        view.backgroundColor = LayoutConstants.backgroundColor
        setUpStubView()
        setUpDoneButton()
        setUpDatePicker()
        setUpCollectionView()
        updateStubViewState()
    }
    
    // MARK: - Internal Methods
    
    func newTrackerViewController(_ vc: UIViewController, didCreateTracker tracker: Tracker) {
        do {
            try trackerStore.add(tracker)
        } catch {
            assertionFailure("TrackersListViewController.newTrackerViewController: error \(error)")
        }
        updateStubViewState()
        vc.dismiss(animated: true)
    }
    
    func newTrackerViewControllerDidCancelCreation(_ vc: UIViewController) {
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
            stubImageView.topAnchor.constraint(equalTo: stubView.topAnchor,
                                               constant: LayoutConstants.Stub.imageToStubViewTop),
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
    
    private func updateStubViewState() {
        setStubView(visible: shouldShowStubView)
    }
    
    private func setStubView(visible: Bool) {
        stubView.isHidden = !visible
        if visible {
            view.bringSubviewToFront(stubView)
        } else {
            view.sendSubviewToBack(stubView)
        }
    }
    
    private func trackerCellViewModel(from tracker: Tracker) -> TrackerCellViewModel {
        let recordText: String
        let daysEnding = ["дней", "день", "дня", "дня", "дня",
                          "дней", "дней", "дней", "дней", "дней"]
        let daysDone: Int
        do {
            daysDone = try recordStore.daysDone(of: tracker)
        } catch {
            assertionFailure("TrackersListViewController.trackerCellViewModel: error \(error)")
            daysDone = 0
        }
        switch tracker.schedule {
        case .regular:
            if (10..<20).contains(daysDone) {
                recordText = "\(daysDone) дней"
                break
            }
            let lastDigit = daysDone % 10
            recordText = "\(daysDone) \(daysEnding[lastDigit])"
        case .irregular:
            if daysDone == 0 {
                recordText = "Не выполнен"
            } else {
                recordText = "Выполнен"
            }
        }
        let isCompleted: Bool
        do {
            isCompleted = try recordStore.isCompleted(trackerID: tracker.id, on: selectedDate)
        } catch {
            assertionFailure("TrackersListViewController.trackerCellViewModel: error \(error)")
            isCompleted = false
        }
        return TrackerCellViewModel(title: tracker.title,
                                    color: UIColor.from(RGBColor: tracker.color),
                                    emoji: tracker.emoji,
                                    recordText: recordText, 
                                    isCompleted: isCompleted)
    }
    
    // MARK: - Private Methods - User Intentions

    @objc private func addTrackerTapped() {
        let creatorVC = NewTrackerViewController(delegate: self, selectedDate: selectedDate, categoryStore: categoryStore)
        present(creatorVC, animated: true)
    }
    
    @objc private func dateChanged() {
        do {
            try trackerStore.set(date: selectedDate)
        } catch {
            assertionFailure("TrackersListViewController.dateChanged: error \(error)")
        }
        collectionView.reloadData()
        updateStubViewState()
    }
    
}


// MARK: - UICollectionViewDataSource
extension TrackersListViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        trackerStore.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        do {
            return try trackerStore.numberOfItemsInSection(section)
        } catch {
            assertionFailure("TrackerViewController.collectionView: error \(error)")
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, 
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.reuseID, for: indexPath) as? TrackerCollectionViewCell else {
            assertionFailure("TrackerViewController.collectionView: Failed to dequeue or typecast cell")
            return UICollectionViewCell()
        }
        let buttonEnabled = !(selectedDate > Date())
        do {
            let tracker = try trackerStore.tracker(at: indexPath)
            cell.configure(with: trackerCellViewModel(from: tracker))
            cell.setTrackerID(tracker.id)
            cell.setRecordButton(enabled: buttonEnabled)
            cell.delegate = self
            return cell
        } catch {
            assertionFailure("TrackerViewController.collectionView: error \(error)")
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CategoryTitleView.reuseID, for: indexPath) as? CategoryTitleView else {
            assertionFailure("TrackerViewController.collectionView: Failed to dequeue supplementary view")
            return   UICollectionReusableView()
        }
        do {
            let title = try trackerStore.sectionTitle(atSectionIndex: indexPath.section)
            view.changeTitleText(title)
        } catch {
            assertionFailure("TrackerViewController.collectionView: error \(error)")
        }
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
        let dummyView = CategoryTitleView()
        let title: String
        do {
            title = try trackerStore.sectionTitle(atSectionIndex: section)
        } catch {
            assertionFailure("TrackerViewController.collectionView: error \(error)")
            title = ""
        }
        dummyView.changeTitleText(title)
        let width = collectionView.frame.width - 2*LayoutConstants.CollectionView.headerLateralPadding
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        return dummyView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
    
}


// MARK: - TrackerCollectionViewCellDelegate
extension TrackersListViewController: TrackerCollectionViewCellDelegate {
    
    func trackerCellDidTapRecord(cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            assertionFailure("TrackerViewController.trackerCellDidTapRecord: Failed to get indexPath of the cell")
            return
        }
        do {
            let tracker = try trackerStore.tracker(at: indexPath)
            let trackerID = tracker.id
            if try recordStore.isCompleted(trackerID: trackerID, on: selectedDate) {
                try recordStore.removeRecord(fromTrackerWithID: trackerID, on: selectedDate)
            } else {
                try recordStore.add(TrackerRecord(id: UUID(), trackerID: trackerID, date: selectedDate))
            }
        } catch {
            assertionFailure("TrackerViewController.collectionView: error \(error)")
            return
        }
    }
}


extension TrackersListViewController: TrackerStoreDelegate {
    func didUpdate(with update: TrackerStoreUpdate) {
        let insertedItemIndexPaths = update.insertedItemIndexPaths
        let insertedSections = update.insertedSections
        collectionView.performBatchUpdates {
            collectionView.insertSections(insertedSections)
            collectionView.insertItems(at: Array(insertedItemIndexPaths))
        }
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
