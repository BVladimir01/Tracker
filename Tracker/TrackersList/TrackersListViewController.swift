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
    private let filterSelectorButton = UIButton(type: .system)
    
    private let categoryStore: CategoryStoreProtocol
    private let analyticsService = AnalyticsService()
    private let viewModel: TrackersListViewModel
    
    // MARK: - Lifecycle
    
    init(trackerStore: TrackerStoreProtocol,
         categoryStore: CategoryStoreProtocol,
         recordStore: RecordStoreProtocol) {
        self.categoryStore = categoryStore
        self.viewModel = TrackersListViewModel(trackerStore: trackerStore,
                                               recordStore: recordStore)
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
        setUpAddTrackerButton()
        setUpDatePicker()
        setUpCollectionView()
        setUpSearch()
        setUpFilterSelectorButton()
        initializeViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        analyticsService.report(event: .open, item: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        analyticsService.report(event: .close, item: nil)
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
    
    private func setUpAddTrackerButton() {
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
        searchController.searchBar.placeholder = Strings.searchControllerPlaceholder
        navigationItem.searchController = searchController
    }
    
    private func setUpFilterSelectorButton() {
        filterSelectorButton.setTitle(Strings.filters, for: .normal)
        filterSelectorButton.setTitleColor(.white, for: .normal)
        filterSelectorButton.titleLabel?.font = LayoutConstants.FilterSelectorButton.font
        filterSelectorButton.backgroundColor = LayoutConstants.FilterSelectorButton.backgroundColor
        filterSelectorButton.layer.cornerRadius = LayoutConstants.FilterSelectorButton.cornerRadius
        filterSelectorButton.layer.masksToBounds = true
        
        filterSelectorButton.addTarget(self,
                                       action: #selector(filterSelectorTapped),
                                       for: .touchUpInside)
        
        view.bringSubviewToFront(filterSelectorButton)
        
        view.addSubview(filterSelectorButton)
        filterSelectorButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterSelectorButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            filterSelectorButton.widthAnchor.constraint(equalToConstant: LayoutConstants.FilterSelectorButton.width),
            filterSelectorButton.heightAnchor.constraint(equalToConstant: LayoutConstants.FilterSelectorButton.height),
            filterSelectorButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                         constant: -LayoutConstants.FilterSelectorButton.spacingToBottomView)
        ])
    }
    
    private func initializeViewModel() {
        viewModel.set(date: datePicker.date)
        viewModel.initialize(with: { [weak self] _ in
            guard let self else { return }
            self.collectionView.reloadData()
            self.datePicker.date = self.viewModel.selectedDate
            self.setStubView(visible: self.viewModel.shouldDisplayStub)
            self.setFilterSelectorButton(visible: self.viewModel.shouldEnableFilterSelection)
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
    
    private func setFilterSelectorButton(visible: Bool) {
        filterSelectorButton.isHidden = !visible
        if visible {
            view.bringSubviewToFront(filterSelectorButton)
        } else {
            view.sendSubviewToBack(filterSelectorButton)
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
                                isCompleted: isCompleted,
                                isPinned: tracker.isPinned)
    }
    
    // MARK: - Private Methods - User Intentions

    @objc private func addTrackerTapped() {
        analyticsService.report(event: .click, item: .addTrack)
        let creatorVC = NewTrackerViewController(delegate: self, selectedDate: datePicker.date, categoryStore: categoryStore)
        present(creatorVC, animated: true)
    }
    
    @objc private func dateChanged() {
        viewModel.set(date: datePicker.date)
    }
    
    @objc private func filterSelectorTapped() {
        analyticsService.report(event: .click, item: .filter)
        present(FilterSelectorViewController(delegate: self,
                                             activeFilter: viewModel.selectedFilter),
                animated: true)
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
        let buttonEnabled = !(datePicker.date > Date())
        cell.configure(with: trackerCellModel(from: tracker))
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
        let cw = collectionView.frame.width
        let spacing = LayoutConstants.CollectionView.interItemSpacing
        let itemWidth = LayoutConstants.CollectionView.itemSize.width
        let insets = collectionView.contentInset.left + collectionView.contentInset.right
        let numberOfItemsInOneRow = Int((cw + spacing - insets) / (itemWidth + spacing))
        let addExtraPadding = (indexPath.section == (collectionView.numberOfSections - 1)
                               && indexPath.item >= (collectionView.numberOfItems(inSection: indexPath.section) - numberOfItemsInOneRow))
        var itemSize = LayoutConstants.CollectionView.itemSize
        itemSize.height += addExtraPadding ? LayoutConstants.CollectionView.extraBottomPadding : 0
        return itemSize
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
        analyticsService.report(event: .click, item: .track)
        viewModel.trackerTapped(at: indexPath)
    }
    
    func menuConfiguration(for cell: TrackerCollectionViewCell) -> UIContextMenuConfiguration? {
        guard let indexPath = collectionView.indexPath(for: cell), let tracker = viewModel.tracker(at: indexPath) else { return nil }
        let isPinned = tracker.isPinned
        let daysDone = viewModel.daysDone(of: tracker)
        let pinUnPinAction = UIAction(title: isPinned ? Strings.contextUnpin : Strings.contextPin) { [weak self] _ in
            guard let self else { return }
            self.viewModel.changePinStatusForTracker(at: indexPath)
        }
        let editAction = UIAction(title: Strings.contextEdit) { [weak self] _ in
            guard let self else { return }
            self.analyticsService.report(event: .click, item: .edit)
            let editorVC = TrackerEditorViewController(oldTracker: tracker, daysDone: daysDone, categoryStore: categoryStore, delegate: self)
            present(editorVC, animated: true)
        }
        let removeAction = UIAction(title: Strings.contextRemove, attributes: [.destructive]) { [weak self] _ in
            let alert = AlertFactory.removeConfirmation(title: Strings.alertTitle,
                                                        removeTitle: Strings.alertRemove,
                                                        cancelTitle: Strings.alertCancel) { [weak self] in
                self?.viewModel.remove(tracker)
            }
            self?.analyticsService.report(event: .click, item: .delete)
            self?.present(alert, animated: true)
        }
        return UIContextMenuConfiguration(actionProvider: { _ in
            UIMenu(children: [pinUnPinAction, editAction, removeAction])
        })
    }
    
}


// MARK: - UISearchResultsUpdating
extension TrackersListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchString = searchController.searchBar.text
    }
}


// MARK: - FilterSelectorViewControllerDelegate
extension TrackersListViewController: FilterSelectorViewControllerDelegate {
    func filterSelector(_ vc: UIViewController, didSelect filter: TrackersListFilter) {
        viewModel.set(filter: filter)
        vc.dismiss(animated: true)
    }
}


// MARK: - TrackerEditorViewControllerDelegate
extension TrackersListViewController: TrackerEditorViewControllerDelegate {
    
    func trackerEditorViewControllerDiDCancel(_ vc: UIViewController) {
        vc.dismiss(animated: true)
    }
    
    func trackerEditorViewController(_ vc: UIViewController, didChange oldTracker: Tracker, to newTracker: Tracker) {
        vc.dismiss(animated: true)
        viewModel.change(oldTracker: oldTracker, to: newTracker)
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
            static let extraBottomPadding: CGFloat = 50
        }
        enum FilterSelectorButton {
            static let spacingToBottomView: CGFloat = 16
            static let width: CGFloat = 114
            static let height: CGFloat = 50
            static let cornerRadius: CGFloat = 16
            static let backgroundColor: UIColor = .ypBlue
            static let textColor: UIColor = .white
            static let font: UIFont = .systemFont(ofSize: 17, weight: .regular)
        }
    }
}


// MARK: - Strings
extension TrackersListViewController {
    enum Strings {
        static let title = NSLocalizedString("trackersListTab.nav_title", comment: "")
        static let stubViewTitle = NSLocalizedString("trackersListTab.stub_title", comment: "")
        static let irregularTrackerIsDone = NSLocalizedString("trackerCell.irregular_tracker_is_done", comment: "")
        static let irregularTrackerNotDone = NSLocalizedString("trackerCell.irregular_tracker_not_done", comment: "")
        static let daysDone = NSLocalizedString("days", comment: "")
        static let searchControllerPlaceholder = NSLocalizedString("trackersListTab.search_placeholder", comment: "")
        static let filters = NSLocalizedString("trackerFilter.filters", comment: "")
        static let contextPin = NSLocalizedString("contextMenu.pin", comment: "")
        static let contextUnpin = NSLocalizedString("contextMenu.unpin", comment: "")
        static let contextEdit = NSLocalizedString("contextMenu.edit", comment: "")
        static let contextRemove = NSLocalizedString("contextMenu.remove", comment: "")
        static let alertTitle = NSLocalizedString("trackersListTab.alert_title", comment: "")
        static let alertRemove = NSLocalizedString("alert.remove", comment: "")
        static let alertCancel = NSLocalizedString("alert.cancel", comment: "")
    }
}
