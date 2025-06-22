//
//  TrackerEditorViewController.swift
//  Tracker
//
//  Created by Vladimir on 20.06.2025.
//


// For reviewer:
// I know it's ugly, and I should modify NewTrackerSetupViewController for this Purpose
// I was running out of time, and copying was the easiest option
import UIKit


// MARK: TrackerEditorViewControllerDelegate
protocol TrackerEditorViewControllerDelegate: AnyObject {
    func trackerEditorViewControllerDiDCancel(_ vc: UIViewController)
    func trackerEditorViewController(_ vc: UIViewController, didChange oldTracker: Tracker, to newTracker: Tracker)
}


// MARK: - TrackerEditorViewController
final class TrackerEditorViewController: UIViewController, EmojisHandlerDelegate, ColorsHandlerDelegate, CategorySelectionViewControllerDelegate, ScheduleSelectionViewControllerDelegate {
    
    // MARK: - Private Properties
    
    private let trackerIsRegular: Bool
    private let categoryStore: CategoryStoreProtocol
    private weak var delegate: TrackerEditorViewControllerDelegate?
    private let oldTracker: Tracker
    private let daysDone: Int
    
    private var trackerCategory: TrackerCategory? {
        didSet {
            settingsTable.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            updateSaveButtonState()
        }
    }
    private var weekdays: Set<Weekday> = [] {
        didSet {
            settingsTable.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
            updateSaveButtonState()
        }
    }
    private var emoji: String? {
        didSet {
            updateSaveButtonState()
        }
    }
    private var color: UIColor? {
        didSet {
            updateSaveButtonState()
        }
    }
    
    private let emojisHandler = EmojisHandler()
    private let colorsHandler = ColorsHandler()
    
    private let titleLabel = UILabel()
    private let daysDoneLabel = UILabel()
    private let trackerTitleView = UIView()
    private let trackerTitleLabel = UILabel()
    private let cancelButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    private let contentView = UIView()
    private let settingsTable = UITableView()
    private let emojisCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let colorsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let contentScrollView = UIScrollView()
    
    private let settingsTableCellReuseID = "subtitleCell"
    
    private var constraints: [NSLayoutConstraint] = []
    
    // MARK: - Initializers
    
    init(oldTracker: Tracker, daysDone: Int, categoryStore: CategoryStoreProtocol, delegate: TrackerEditorViewControllerDelegate) {
        self.oldTracker = oldTracker
        self.daysDone = daysDone
        self.categoryStore = categoryStore
        self.delegate = delegate
        switch oldTracker.schedule {
        case .regular:
            trackerIsRegular = true
        case .irregular:
            trackerIsRegular = false
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init not implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LayoutConstants.backgroundColor
        setUpTitleAndScrollView()
        setUpDaysDoneLabel()
        setUpTrackerTitleView()
        setUpCancelButton()
        setUpSaveButton()
        setUpSettingsTable()
        setUpEmojisCollectionView()
        setUpColorsCollectionView()
        NSLayoutConstraint.activate(constraints)
        colorsHandler.delegate = self
        emojisHandler.delegate = self
        initializeViewWithTrackerData()
    }
    
    // MARK: - Interntal Methods
    
    func scheduleSelectionViewController(_ vc: UIViewController, didSelect weekdays: Set<Weekday>) {
        self.weekdays = weekdays
        vc.dismiss(animated: true)
    }
    
    func categorySelectionViewController(_ vc: UIViewController, didDismissWith category: TrackerCategory?) {
        self.trackerCategory = category
        vc.dismiss(animated: true)
    }
    
    func emojisHandler(_ handler: EmojisHandler, didSelect emoji: String) {
        self.emoji = emoji
    }
    
    func colorsHandler(_ handler: ColorsHandler, didSelect color: UIColor) {
        self.color = color
    }
    
    // MARK: - Private Methods - Setup
    
    private func initializeViewWithTrackerData() {
        // layout collectionViewsFirst
        emojisCollectionView.layoutIfNeeded()
        colorsCollectionView.layoutIfNeeded()
        
        trackerCategory = oldTracker.category
        switch oldTracker.schedule {
        case .regular(let weekdays):
            self.weekdays = weekdays
        case .irregular:
            break
        }
        for emojiIndex in 0..<emojisCollectionView.numberOfItems(inSection: 0) {
            guard let cell = emojisCollectionView.cellForItem(at: IndexPath(item: emojiIndex, section: 0)) as? EmojisCollectionViewCell else {
                assertionFailure("TrackerEditorViewController.initializeViewWithTrackerData: failed to typecast EmojisCollectionViewCell")
                continue
            }
            if String(oldTracker.emoji) == cell.emoji {
                emojisCollectionView.selectItem(at: IndexPath(item: emojiIndex, section: 0),
                                                animated: true, scrollPosition: .centeredVertically)
                emoji = cell.emoji
            }
            
        }
        for colorIndex in 0..<colorsCollectionView.numberOfItems(inSection: 0) {
            guard let cell = colorsCollectionView.cellForItem(at: IndexPath(item: colorIndex, section: 0)) as? ColorsCollectionViewCell else {
                assertionFailure("TrackerEditorViewController.initializeViewWithTrackerData: failed to typecast ColorsCollectionViewCell")
                continue
            }
            guard let cellColor = cell.color.rgbColor else {
                assertionFailure("TrackerEditorViewController.initializeViewWithTrackerData: failed to get rgbColor from UIColor")
                continue
            }
            if oldTracker.color == cellColor {
                colorsCollectionView.selectItem(at: IndexPath(item: colorIndex, section: 0),
                                                animated: true, scrollPosition: .centeredVertically)
                color = cell.color
            }
        }
    }
    
    private func setUpTitleAndScrollView() {
        titleLabel.text = trackerIsRegular ? Strings.regularTitle : Strings.irregularTitle
        titleLabel.font = LayoutConstants.Title.font
        titleLabel.textColor = LayoutConstants.Title.textColor
        titleLabel.textAlignment = .center
        
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(contentsOf: [
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                       constant: LayoutConstants.Title.topPadding)
        ])
        
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(contentsOf: [
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                            constant: LayoutConstants.ScrollView.topSpacing),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor,
                                               constant: -LayoutConstants.ScrollView.bottomSpacing)
        ])
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(contentsOf: [
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setUpDaysDoneLabel() {
        let text: String
        if trackerIsRegular {
            text = String(format: Strings.daysDone, daysDone)
        } else {
            if daysDone == 0 {
                text = Strings.irregularTrackerNotDone
            } else {
                text = Strings.irregularTrackerIsDone
            }
        }
        daysDoneLabel.text = text
        daysDoneLabel.textColor = LayoutConstants.DaysDoneLabel.textColor
        daysDoneLabel.font = LayoutConstants.DaysDoneLabel.font
        daysDoneLabel.backgroundColor = .clear
        daysDoneLabel.textAlignment = .center
        
        contentView.addSubview(daysDoneLabel)
        daysDoneLabel.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(contentsOf: [
            daysDoneLabel.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            daysDoneLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            daysDoneLabel.heightAnchor.constraint(equalToConstant: LayoutConstants.DaysDoneLabel.height),
            daysDoneLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor,
                                                   constant: LayoutConstants.DaysDoneLabel.lateralPadding),
            daysDoneLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor,
                                                    constant: -LayoutConstants.DaysDoneLabel.lateralPadding)
        ])
    }
    
    private func setUpTrackerTitleView() {
        trackerTitleView.layer.cornerRadius = LayoutConstants.TrackerTitleView.cornerRadius
        trackerTitleView.backgroundColor = LayoutConstants.TrackerTitleView.backgroundColor
        trackerTitleView.layer.masksToBounds = true
        
        contentView.addSubview(trackerTitleView)
        trackerTitleView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(contentsOf: [
            trackerTitleView.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            trackerTitleView.topAnchor.constraint(equalTo: daysDoneLabel.bottomAnchor,
                                                            constant: LayoutConstants.TrackerTitleView.spacingToTopView),
            trackerTitleView.widthAnchor.constraint(equalToConstant: LayoutConstants.TrackerTitleView.width),
            trackerTitleView.heightAnchor.constraint(equalToConstant: LayoutConstants.TrackerTitleView.height)
        ])
        
        trackerTitleLabel.text = oldTracker.title
        trackerTitleLabel.textColor = LayoutConstants.TrackerTitleView.textColor
        trackerTitleLabel.font = LayoutConstants.TrackerTitleView.font
        
        trackerTitleView.addSubview(trackerTitleLabel)
        trackerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(contentsOf: [
            trackerTitleLabel.centerXAnchor.constraint(equalTo: trackerTitleView.centerXAnchor),
            trackerTitleLabel.topAnchor.constraint(equalTo: trackerTitleView.topAnchor,
                                                   constant: LayoutConstants.TrackerTitleView.labelVerticalPadding),
            trackerTitleLabel.widthAnchor.constraint(equalToConstant: LayoutConstants.TrackerTitleView.labelWidth),
            trackerTitleView.bottomAnchor.constraint(equalTo: trackerTitleView.bottomAnchor, constant: -LayoutConstants.TrackerTitleView.labelVerticalPadding)
        ])
    }
    
    private func setUpCancelButton() {
        cancelButton.setTitle(Strings.cancelButtonTitle, for: .normal)
        cancelButton.setTitleColor(LayoutConstants.Buttons.cancelButtonColor, for: .normal)
        cancelButton.titleLabel?.font = LayoutConstants.Buttons.font
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.layer.cornerRadius = LayoutConstants.Buttons.cornerRadius
        cancelButton.layer.borderWidth = LayoutConstants.Buttons.cancelButtonBorderWidth
        cancelButton.layer.borderColor = LayoutConstants.Buttons.cancelButtonColor.cgColor
        
        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(contentsOf: [
            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                  constant: LayoutConstants.Buttons.lateralPadding),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                 constant: LayoutConstants.Buttons.bottomPadding),
            cancelButton.widthAnchor.constraint(equalToConstant: LayoutConstants.Buttons.cancelButtonWidth),
            cancelButton.heightAnchor.constraint(equalToConstant: LayoutConstants.Buttons.height)
        ])
    }
    
    private func setUpSaveButton() {
        saveButton.setTitle(Strings.saveButtonTitle, for: .normal)
        saveButton.backgroundColor = LayoutConstants.Buttons.saveButtonBackgroundColor
        saveButton.setTitleColor(LayoutConstants.Buttons.saveButtonTextColor, for: .normal)
        saveButton.titleLabel?.font = LayoutConstants.Buttons.font
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        saveButton.layer.cornerRadius = LayoutConstants.Buttons.cornerRadius
        
        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(contentsOf: [
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                  constant: -LayoutConstants.Buttons.lateralPadding),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                 constant: LayoutConstants.Buttons.bottomPadding),
            saveButton.widthAnchor.constraint(equalToConstant: LayoutConstants.Buttons.saveButtonWidth),
            saveButton.heightAnchor.constraint(equalToConstant: LayoutConstants.Buttons.height)
        ])
    }
    
    private func setUpSettingsTable() {
        settingsTable.layer.masksToBounds = true
        settingsTable.layer.cornerRadius = LayoutConstants.SettingsTable.cornerRadius
        
        settingsTable.delegate = self
        settingsTable.dataSource = self
        settingsTable.rowHeight = LayoutConstants.SettingsTable.rowHeight
        settingsTable.isScrollEnabled = false
        settingsTable.separatorStyle = .singleLine
        settingsTable.separatorInset = LayoutConstants.SettingsTable.separatorInset
        settingsTable.separatorColor = LayoutConstants.SettingsTable.separatorColor
        settingsTable.register(UITableViewCell.self, forCellReuseIdentifier: settingsTableCellReuseID)
        
        contentView.addSubview(settingsTable)
        settingsTable.translatesAutoresizingMaskIntoConstraints = false
        let tableHeight = (trackerIsRegular ? 2 : 1)*LayoutConstants.SettingsTable.rowHeight
        constraints.append(contentsOf: [
            settingsTable.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            settingsTable.widthAnchor.constraint(equalToConstant: LayoutConstants.SettingsTable.width),
            settingsTable.topAnchor.constraint(equalTo: trackerTitleView.bottomAnchor,
                                       constant: LayoutConstants.SettingsTable.spacingToTopView),
            settingsTable.heightAnchor.constraint(equalToConstant: tableHeight)
        ])
    }
    
    private func setUpEmojisCollectionView() {
        let emojiTitle = UILabel()
        emojiTitle.text = Strings.emojiCollectionTitle
        emojiTitle.textColor = LayoutConstants.SelectionCollectionView.titleColor
        emojiTitle.font = LayoutConstants.SelectionCollectionView.titleFont
        contentView.addSubview(emojiTitle)
        emojiTitle.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(contentsOf: [
            emojiTitle.topAnchor.constraint(equalTo: settingsTable.bottomAnchor,
                                            constant: LayoutConstants.SelectionCollectionView.emojiTopSpacing),
            emojiTitle.leftAnchor.constraint(equalTo: contentView.leftAnchor,
                                             constant: LayoutConstants.SelectionCollectionView.titleLeadingSpacing)
        ])
        
        contentView.addSubview(emojisCollectionView)
        emojisCollectionView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(contentsOf: [
            emojisCollectionView.topAnchor.constraint(equalTo: emojiTitle.bottomAnchor,
                                             constant: LayoutConstants.SelectionCollectionView.collectionViewTopSpacing),
            emojisCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                 constant: LayoutConstants.SelectionCollectionView.collectionViewLateralSpacing),
            emojisCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                  constant: -LayoutConstants.SelectionCollectionView.collectionViewLateralSpacing),
            emojisCollectionView.heightAnchor.constraint(equalToConstant: LayoutConstants.SelectionCollectionView.collectionViewHeight)
        ])
        emojisCollectionView.register(EmojisCollectionViewCell.self,
                                      forCellWithReuseIdentifier: EmojisCollectionViewCell.reuseID)
        emojisCollectionView.delegate = emojisHandler
        emojisCollectionView.dataSource = emojisHandler
    }
    
    private func setUpColorsCollectionView() {
        let colorTitle = UILabel()
        colorTitle.text = Strings.colorCollectionTitle
        colorTitle.textColor = LayoutConstants.SelectionCollectionView.titleColor
        colorTitle.font = LayoutConstants.SelectionCollectionView.titleFont
        contentView.addSubview(colorTitle)
        colorTitle.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(contentsOf: [
            colorTitle.topAnchor.constraint(equalTo: emojisCollectionView.bottomAnchor,
                                            constant: LayoutConstants.SelectionCollectionView.colorTopSpacing),
            colorTitle.leftAnchor.constraint(equalTo: contentView.leftAnchor,
                                             constant: LayoutConstants.SelectionCollectionView.titleLeadingSpacing)
        ])
        
        contentView.addSubview(colorsCollectionView)
        colorsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(contentsOf: [
            colorsCollectionView.topAnchor.constraint(equalTo: colorTitle.bottomAnchor,
                                             constant: LayoutConstants.SelectionCollectionView.collectionViewTopSpacing),
            colorsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                 constant: LayoutConstants.SelectionCollectionView.collectionViewLateralSpacing),
            colorsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                  constant: -LayoutConstants.SelectionCollectionView.collectionViewLateralSpacing),
            colorsCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            colorsCollectionView.heightAnchor.constraint(equalToConstant: LayoutConstants.SelectionCollectionView.collectionViewHeight)
        ])
        colorsCollectionView.register(ColorsCollectionViewCell.self,
                                      forCellWithReuseIdentifier: ColorsCollectionViewCell.reuseID)
        colorsCollectionView.delegate = colorsHandler
        colorsCollectionView.dataSource = colorsHandler
    }
    
    // MARK: - Private Methods - Helpers
    
    private func updateSaveButtonState() {
        let shouldEnableSaveButton: Bool
        if trackerCategory != nil, color != nil, emoji != nil,
           !weekdays.isEmpty || !trackerIsRegular {
            shouldEnableSaveButton = true
        } else {
            shouldEnableSaveButton = false
        }
        setSaveButton(enabled: shouldEnableSaveButton)
    }
    
    private func setSaveButton(enabled: Bool) {
        let color = enabled ? LayoutConstants.Buttons.saveButtonBackgroundColor : LayoutConstants.Buttons.saveButtonDisabledColor
        let textColor = enabled ? LayoutConstants.Buttons.saveButtonTextColor : LayoutConstants.Buttons.saveButtonDisabledTextColor
        saveButton.isEnabled = enabled
        saveButton.backgroundColor = color
        saveButton.setTitleColor(textColor, for: .normal)
    }
    
    // MARK: - Private Methods - Intentions
    
    @objc
    private func cancelButtonTapped() {
        delegate?.trackerEditorViewControllerDiDCancel(self)
    }
    
    @objc
    private func saveButtonTapped() {
        guard let trackerCategory else {
            assertionFailure("TrackerEditorViewController.createButtonTapped: Failed to get tracker category")
            return
        }
        guard let emoji , let rgbColor = color?.rgbColor else {
            assertionFailure("TrackerEditorViewController.createButtonTapped: Failed to unwrap color or emoji")
            return
        }
        
        let schedule: Schedule = trackerIsRegular ? .regular(weekdays) : oldTracker.schedule
        let tracker = Tracker(id: UUID(),
                              title: oldTracker.title,
                              color: rgbColor,
                              emoji: Character(emoji),
                              schedule: schedule,
                              category: trackerCategory,
                              isPinned: false
        )
        delegate?.trackerEditorViewController(self, didChange: oldTracker, to: tracker)
    }
    
    private func chooseCategoryTapped() {
        let vm = CategorySelectionViewModel(categoryStore: categoryStore,
                                                                    selectedCategory: trackerCategory)
        let vc = CategorySelectionViewController(delegate: self,
                                                 categoryStore: categoryStore,
                                                 viewModel: vm)
        present(vc, animated: true)
    }
    
    private func chooseScheduleTapped() {
        let vc = ScheduleSelectionViewController()
        vc.delegate = self
        vc.selectedWeekdays = weekdays
        present(vc, animated: true)
    }
    
}


// MARK: - UITableViewDataSource
extension TrackerEditorViewController: UITableViewDataSource {
    
    private func configureCategoryCell(_ cell: UITableViewCell) {
        cell.backgroundColor = LayoutConstants.SettingsTable.cellBackgroundColor
        
        cell.textLabel?.text = Strings.categoryConfigTitle
        cell.textLabel?.font = LayoutConstants.SettingsTable.cellTextFont
        cell.textLabel?.textColor = LayoutConstants.SettingsTable.cellTextColor
        
        cell.detailTextLabel?.text = trackerCategory?.title
        cell.detailTextLabel?.font = LayoutConstants.SettingsTable.cellTextFont
        cell.detailTextLabel?.textColor = LayoutConstants.SettingsTable.cellDetailTextColor
        
        cell.accessoryType = .disclosureIndicator
    }
    
    private func configureScheduleCell(_ cell: UITableViewCell) {
        cell.backgroundColor = LayoutConstants.SettingsTable.cellBackgroundColor
        
        cell.textLabel?.text = Strings.scheduleConfigTitle
        cell.textLabel?.font = LayoutConstants.SettingsTable.cellTextFont
        cell.textLabel?.textColor = LayoutConstants.SettingsTable.cellTextColor
        
        let weekdaysAsStrings = weekdays.sorted().map { $0.asString(short: true) }
        cell.detailTextLabel?.text = weekdaysAsStrings.joined(separator: ", ")
        if weekdays.count == Weekday.allCases.count {
            cell.detailTextLabel?.text = Strings.scheduleEveryDay
        }
        cell.detailTextLabel?.font = LayoutConstants.SettingsTable.cellTextFont
        cell.detailTextLabel?.textColor = LayoutConstants.SettingsTable.cellDetailTextColor
        
        cell.accessoryType = .disclosureIndicator
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackerIsRegular ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: settingsTableCellReuseID)
        if indexPath.row == 0 {
            configureCategoryCell(cell)
        } else if indexPath.row == 1 {
            configureScheduleCell(cell)
        } else {
            assertionFailure("TrackerEditorViewController.tableView: wrong indexPath")
        }
        if indexPath.row == self.tableView(tableView, numberOfRowsInSection: 0) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        return cell
    }
    
}


// MARK: - UITableViewDelegate
extension TrackerEditorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            chooseCategoryTapped()
        } else if indexPath.row == 1{
            chooseScheduleTapped()
        } else {
            assertionFailure("TrackerEditorViewController.tableView: wrong IndexPath")
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

// MARK: - UITextFieldDelegate
extension TrackerEditorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


// MARK: - LayoutConstants
extension TrackerEditorViewController {
    enum LayoutConstants {
        static let backgroundColor: UIColor = .ypWhite
        enum Title {
            static let font: UIFont = .systemFont(ofSize: 16, weight: .medium)
            static let textColor: UIColor = .ypBlack
            static let topPadding: CGFloat = 27
        }
        enum DaysDoneLabel {
            static let textColor: UIColor = .ypBlack
            static let font: UIFont = .systemFont(ofSize: 32, weight: .bold)
            static let lateralPadding: CGFloat = 16
            static let spacingToTopView: CGFloat = 38
            static let height: CGFloat = 38
        }
        enum TrackerTitleView {
            static let spacingToTopView: CGFloat = 40
            static let width: CGFloat = 344
            static let height: CGFloat = 75
            static let backgroundColor: UIColor = .ypBackground
            static let textColor: UIColor = .ypBlack
            static let font: UIFont = .systemFont(ofSize: 17, weight: .regular)
            static let labelWidth: CGFloat = 286
            static let labelVerticalPadding: CGFloat = 6
            static let cornerRadius: CGFloat = 16
        }
        enum Buttons {
            static let cancelButtonColor: UIColor = .ypRed
            static let cancelButtonBackgroundColor: UIColor = .ypWhite
            static let cancelButtonBorderWidth: CGFloat = 1
            static let cancelButtonWidth: CGFloat = 166
            
            static let saveButtonBackgroundColor: UIColor = .ypBlack
            static let saveButtonTextColor: UIColor = .ypWhite
            static let saveButtonDisabledColor: UIColor = .ypGray
            static let saveButtonDisabledTextColor: UIColor = .white
            static let saveButtonWidth: CGFloat = 161
            
            static let bottomPadding: CGFloat = 0
            static let lateralPadding: CGFloat = 20
            static let height: CGFloat = 60
            static let font: UIFont = .systemFont(ofSize: 16, weight: .medium)
            static let cornerRadius: CGFloat = 16
        }
        enum SettingsTable {
            static let cornerRadius: CGFloat = 16
            static let rowHeight: CGFloat = 75
            static let width: CGFloat = 343
            static let spacingToTopView: CGFloat = 24
            static let separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            static let separatorColor: UIColor = .gray
            
            static let cellTextFont: UIFont = .systemFont(ofSize: 17, weight: .regular)
            static let cellTextColor: UIColor = .ypBlack
            static let cellDetailTextColor: UIColor = .ypGray
            static let cellBackgroundColor: UIColor = .ypBackground
        }
        enum SelectionCollectionView {
            static let titleFont: UIFont = .systemFont(ofSize: 19, weight: .bold)
            static let titleColor: UIColor = .ypBlack
            static let emojiTopSpacing: CGFloat = 32
            static let colorTopSpacing: CGFloat = 16
            static let titleLeadingSpacing: CGFloat = 28
            static let collectionViewTopSpacing: CGFloat = 0
            static let collectionViewLateralSpacing: CGFloat = 0
            static let collectionViewHeight: CGFloat = 204
        }
        enum ScrollView {
            static let topSpacing: CGFloat = 14
            static let bottomSpacing: CGFloat = 16
            
        }
    }
}


// MARK: - Strings
extension TrackerEditorViewController {
    enum Strings {
        static let regularTitle = NSLocalizedString("TrackerEditorViewController.regular_tracker_view_title", comment: "")
        static let irregularTitle = NSLocalizedString("TrackerEditorViewController.irregular_tracker_view_title", comment: "")
        static let cancelButtonTitle = NSLocalizedString("TrackerEditorViewController.cancelButton_title", comment: "")
        static let saveButtonTitle = NSLocalizedString("TrackerEditorViewController.saveButton_title", comment: "")
        static let emojiCollectionTitle = NSLocalizedString("newTrackerSetup.emojiCollection_title", comment: "")
        static let colorCollectionTitle = NSLocalizedString("newTrackerSetup.colorCollection_title", comment: "")
        static let scheduleConfigTitle = NSLocalizedString("newTrackerSetup.Schedule_config_title", comment: "")
        static let categoryConfigTitle = NSLocalizedString("newTrackerSetup.Category_config_title", comment: "")
        static let scheduleEveryDay = NSLocalizedString("newTrackerSetup.Schedule_config_description.every_day", comment: "")
        static let irregularTrackerIsDone = NSLocalizedString("trackerCell.irregular_tracker_is_done", comment: "")
        static let irregularTrackerNotDone = NSLocalizedString("trackerCell.irregular_tracker_not_done", comment: "")
        static let daysDone = NSLocalizedString("days", comment: "")
    }
}
