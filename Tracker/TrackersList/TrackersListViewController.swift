//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Vladimir on 01.05.2025.
//

import UIKit


// MARK: - TrackersListViewController
final class TrackersListViewController: UIViewController {
    
    // MARK: - Private Properties

    private let collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: UICollectionViewFlowLayout())
    private let stubView = UIView()
    private let datePicker = UIDatePicker()
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let categoryStore: CategoryStore
    
    private let viewModel: TrackersListViewModel
    
    private var selectedDate: Date {
        datePicker.date
    }
    
    // MARK: - Lifecycle
    
    init(trackerDataStores: TrackerDataStores) {
        self.categoryStore = trackerDataStores.categoryStore
        self.viewModel = TrackersListViewModel(trackerStore: trackerDataStores.trackerStore,
                                               recordStore: trackerDataStores.recordStore)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.title
        view.backgroundColor = LayoutConstants.backgroundColor
        setUpStubView()
        setUpDoneButton()
        setUpDatePicker()
        setUpCollectionView()
        initializeViewModel()
        setUpSearch()
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
        label.text = Strings.stubViewTitle
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
    
    private func setUpSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
    }
    
    private func initializeViewModel() {
        viewModel.selectedDate = datePicker.date
        viewModel.initialize(with: { [weak self] _ in
            self?.collectionView.reloadData()
        })
    }
    
    // MARK: - Private Methods - Helpers
    
    private func setStubView(visible: Bool) {
        stubView.isHidden = !visible
        if visible {
            view.bringSubviewToFront(stubView)
        } else {
            view.sendSubviewToBack(stubView)
        }
    }
    
    private func trackerCellModel(from tracker: Tracker) -> TrackerCellModel {
        let recordText: String
        let daysDone = viewModel.daysDone(of: tracker)
        switch tracker.schedule {
        case .regular:
            recordText = String(format: Strings.daysDone, daysDone)
        case .irregular:
            if daysDone == 0 {
                recordText = Strings.irregularTrackerNotDone
            } else {
                recordText = Strings.irregularTrackerIsDone
            }
        }
        let isCompleted = viewModel.isCompleted(tracker: tracker)
        return TrackerCellModel(title: tracker.title,
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
        viewModel.selectedDate = datePicker.date
    }
    
}


// MARK: - UICollectionViewDataSource
extension TrackersListViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection(section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, 
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.reuseID, for: indexPath) as? TrackerCollectionViewCell else {
            assertionFailure("TrackerViewController.collectionView: Failed to dequeue or typecast cell")
            return UICollectionViewCell()
        }
        guard let tracker = viewModel.tracker(at: indexPath) else {
            assertionFailure("TrackerViewController.collectionView: Failed to get tracker for indexPath")
            return UICollectionViewCell()
        }
        let buttonEnabled = !(selectedDate > Date())
        cell.configure(with: trackerCellModel(from: tracker))
        cell.setTrackerID(tracker.id)
        cell.setRecordButton(enabled: buttonEnabled)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CategoryTitleView.reuseID, for: indexPath) as? CategoryTitleView else {
            assertionFailure("TrackerViewController.collectionView: Failed to dequeue supplementary view")
            return UICollectionReusableView()
        }
        let title = viewModel.sectionTitle(at: indexPath.section)
        if title == nil {
            assertionFailure("TrackerViewController.collectionView: Failed to get title for supplementary view at \(indexPath)")
        }
        view.changeTitleText(title ?? "" )
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
        let title = viewModel.sectionTitle(at: section)
        if title == nil {
            assertionFailure("TrackerViewController.collectionView: Failed to get title for supplementary view for section \(section)")
        }
        let dummyView = CategoryTitleView()
        dummyView.changeTitleText(title ?? "")
        let width = collectionView.frame.width - 2*LayoutConstants.CollectionView.headerLateralPadding
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        return dummyView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
    
}


// MARK: - NewTrackerViewControllerDelegate
extension TrackersListViewController: NewTrackerViewControllerDelegate {
    
    func newTrackerViewController(_ vc: UIViewController, didCreateTracker tracker: Tracker) {
        viewModel.add(tracker)
        vc.dismiss(animated: true)
    }
    
    func newTrackerViewControllerDidCancelCreation(_ vc: UIViewController) {
        vc.dismiss(animated: true)
    }
    
}


// MARK: - TrackerCollectionViewCellDelegate
extension TrackersListViewController: TrackerCollectionViewCellDelegate {
    func trackerCellDidTapRecord(cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            assertionFailure("TrackerViewController.trackerCellDidTapRecord: Failed to get indexPath of the cell")
            return
        }
        viewModel.trackerTapped(at: indexPath)
    }
}


// MARK: - UISearchResultsUpdating
extension TrackersListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchString = searchController.searchBar.text
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


// MARK: - Strings
extension TrackersListViewController {
    enum Strings {
        static let title = NSLocalizedString("trackersListTab.nav_title", comment: "")
        static let stubViewTitle = NSLocalizedString("trackersListTab.stub_title", comment: "")
        static let irregularTrackerIsDone = NSLocalizedString("trackersListTab.cell.irregular_tracker_is_done", comment: "")
        static let irregularTrackerNotDone = NSLocalizedString("trackersListTab.cell.irregular_tracker_not_done", comment: "")
        static let daysDone = NSLocalizedString("days", comment: "")
    }
}
