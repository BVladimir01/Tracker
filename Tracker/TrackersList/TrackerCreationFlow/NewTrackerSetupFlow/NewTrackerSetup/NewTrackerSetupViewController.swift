//
//  NewTrackerSetupViewController.swift
//  Tracker
//
//  Created by Vladimir on 10.05.2025.
//

import UIKit


// MARK: NewTrackerSetupViewControllerDelegate
protocol NewTrackerSetupViewControllerDelegate: AnyObject {
    func newTrackerSetupViewController(_ vc: UIViewController, didCreateTracker tracker: Tracker)
    func newTrackerSetupViewControllerDidCancelCreation(_ vc: UIViewController)
}


// MARK: - NewTrackerSetupViewController
final class NewTrackerSetupViewController: UIViewController, ScheduleSelectionViewControllerDelegate, CategorySelectionViewControllerDelegate, EmojisHandlerDelegate, ColorsHandlerDelegate {
    
    // MARK: - Private Properties
    
    private var trackerIsRegular: Bool
    private var categoryStore: CategoryStoreProtocol
    private var selectedDate: Date
    private weak var delegate: NewTrackerSetupViewControllerDelegate?
    
    private var trackerCategory: TrackerCategory? {
        didSet {
            settingsTable.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            updateCreateButtonState()
        }
    }
    private var weekdays: Set<Weekday> = [] {
        didSet {
            settingsTable.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
            updateCreateButtonState()
        }
    }
    private var emoji: String? {
        didSet {
            updateCreateButtonState()
        }
    }
    private var color: UIColor? {
        didSet {
            updateCreateButtonState()
        }
    }
    
    private let emojisHandler = EmojisHandler()
    private let colorsHandler = ColorsHandler()
    
    private let nameTextField = UITextField()
    private let cancelButton = UIButton(type: .system)
    private let createButton = UIButton(type: .system)
    private let contentView = UIView()
    private let settingsTable = UITableView()
    private let emojisCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let colorsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let contentScrollView = UIScrollView()
    
    private let settingsTableCellReuseID = "subtitleCell"
    
    private var constraints: [NSLayoutConstraint] = []
    
    private var shouldEnableCreateButton: Bool {
        if let trackerName = nameTextField.text, !trackerName.isEmpty,
           trackerCategory != nil, color != nil, emoji != nil,
           !weekdays.isEmpty || !trackerIsRegular {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Initializers
    
    init(trackerIsRegular: Bool, categoryStore: CategoryStoreProtocol, selectedDate: Date, delegate: NewTrackerSetupViewControllerDelegate) {
        self.trackerIsRegular = trackerIsRegular
        self.categoryStore = categoryStore
        self.selectedDate = selectedDate
        self.delegate = delegate
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
        setUpNameTextField()
        setUpCancelButton()
        setUpCreateButton()
        setUpSettingsTable()
        setUpEmojisCollectionView()
        setUpColorsCollectionView()
        NSLayoutConstraint.activate(constraints)
        colorsHandler.delegate = self
        emojisHandler.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
    }
    
    // MARK: - Interntal Methods
    
    func scheduleSelectionViewController(_ vc: UIViewController, didSelect weekdays: Set<Weekday>) {
        self.weekdays = weekdays
        vc.dismiss(animated: true)
    }
    
    func categorySelectionViewController(_ vc: UIViewController, didDismissWith category: TrackerCategory?) {
        self.trackerCategory = category
    }
    
    func emojisHandler(_ handler: EmojisHandler, didSelect emoji: String) {
        self.emoji = emoji
    }
    
    func colorsHandler(_ handler: ColorsHandler, didSelect color: UIColor) {
        self.color = color
    }
    
    // MARK: - Private Methods - Setup
    
    private func setUpTitleAndScrollView() {
        let title = UILabel()
        title.text = trackerIsRegular ? Strings.regularTitle : Strings.irregularTitle
        title.font = LayoutConstants.Title.font
        title.textColor = LayoutConstants.Title.textColor
        title.textAlignment = .center
        
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(contentsOf: [
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                       constant: LayoutConstants.Title.topPadding)
        ])
        
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(contentsOf: [
            scrollView.topAnchor.constraint(equalTo: title.bottomAnchor,
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
//        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private func setUpNameTextField() {
        nameTextField.placeholder = Strings.textFieldPlaceholderTitle
        nameTextField.borderStyle = .none
        nameTextField.layer.cornerRadius = LayoutConstants.TextField.cornerRadius
        nameTextField.layer.masksToBounds = true
        nameTextField.textColor = LayoutConstants.TextField.textColor
        nameTextField.backgroundColor = LayoutConstants.TextField.backgroundColor
        nameTextField.addTarget(self, action: #selector(nameTextFieldEditingChange(_:)), for: .editingChanged)
        nameTextField.delegate = self
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0,
                                                   width: LayoutConstants.TextField.innerLeftPadding,
                                                   height: LayoutConstants.TextField.height))
        leftPaddingView.alpha = 0
        nameTextField.leftView = leftPaddingView
        nameTextField.leftViewMode = .always
        
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0,
                                                   width: LayoutConstants.TextField.innerRightPadding,
                                                   height: LayoutConstants.TextField.height))
        rightPaddingView.alpha = 0
        nameTextField.rightView = rightPaddingView
        nameTextField.rightViewMode = .always
        
        contentView.addSubview(nameTextField)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(contentsOf: [
            nameTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor,
                                               constant: LayoutConstants.TextField.topPadding),
            nameTextField.widthAnchor.constraint(equalToConstant: LayoutConstants.TextField.width),
            nameTextField.heightAnchor.constraint(equalToConstant: LayoutConstants.TextField.height)
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
    
    private func setUpCreateButton() {
        createButton.setTitle(Strings.createButtonTitle, for: .normal)
        createButton.backgroundColor = LayoutConstants.Buttons.createButtonBackgroundColor
        createButton.setTitleColor(LayoutConstants.Buttons.createButtonTextColor, for: .normal)
        createButton.titleLabel?.font = LayoutConstants.Buttons.font
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        createButton.layer.cornerRadius = LayoutConstants.Buttons.cornerRadius
        updateCreateButtonState()
        
        view.addSubview(createButton)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(contentsOf: [
            createButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                  constant: -LayoutConstants.Buttons.lateralPadding),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                 constant: LayoutConstants.Buttons.bottomPadding),
            createButton.widthAnchor.constraint(equalToConstant: LayoutConstants.Buttons.createButtonWidth),
            createButton.heightAnchor.constraint(equalToConstant: LayoutConstants.Buttons.height)
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
            settingsTable.topAnchor.constraint(equalTo: nameTextField.bottomAnchor,
                                       constant: LayoutConstants.SettingsTable.spacingToTextField),
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
    
    private func updateCreateButtonState() {
        setCreateButton(enabled: shouldEnableCreateButton)
    }
    
    private func setCreateButton(enabled: Bool) {
        let color = enabled ? LayoutConstants.Buttons.createButtonBackgroundColor : LayoutConstants.Buttons.createButtonDisabledColor
        let textColor = enabled ? LayoutConstants.Buttons.createButtonTextColor : LayoutConstants.Buttons.createButtonDisabledTextColor
        createButton.isEnabled = enabled
        createButton.backgroundColor = color
        createButton.setTitleColor(textColor, for: .normal)
    }
    
    // MARK: - Private Methods - Intentions
    
    @objc
    private func cancelButtonTapped() {
        delegate?.newTrackerSetupViewControllerDidCancelCreation(self)
    }
    
    @objc
    private func createButtonTapped() {
        guard let trackerTitle = nameTextField.text else {
            assertionFailure("NewTrackerSetupViewController.createButtonTapped: Failed to get category title")
            return
        }
        guard let trackerCategory else {
            assertionFailure("NewTrackerSetupViewController.createButtonTapped: Failed to get tracker category")
            return
        }
        guard let emoji , let rgbColor = color?.rgbColor else {
            assertionFailure("NewTrackerSetupViewController.createButtonTapped: Failed to unwrap color or emoji")
            return
        }
        let schedule: Schedule = trackerIsRegular ? .regular(weekdays) : .irregular(selectedDate)
        let tracker = Tracker(id: UUID(),
                              title: trackerTitle,
                              color: rgbColor,
                              emoji: Character(emoji),
                              schedule: schedule,
                              category: trackerCategory,
                              isPinned: false
        )
        delegate?.newTrackerSetupViewController(self, didCreateTracker: tracker)
    }
    
    private func chooseCategoryTapped() {
        nameTextField.resignFirstResponder()
        let vm = CategorySelectionViewModel(categoryStore: categoryStore,
                                                                    selectedCategory: trackerCategory)
        let vc = CategorySelectionViewController(delegate: self,
                                                 categoryStore: categoryStore,
                                                 viewModel: vm)
        present(vc, animated: true)
    }
    
    private func chooseScheduleTapped() {
        nameTextField.resignFirstResponder()
        let vc = ScheduleSelectionViewController()
        vc.delegate = self
        vc.initialWeekdays = weekdays
        present(vc, animated: true)
    }
    
    @objc
    private func nameTextFieldEditingChange(_ sender: UITextField) {
        updateCreateButtonState()
    }
    
}


// MARK: - UITableViewDataSource
extension NewTrackerSetupViewController: UITableViewDataSource {
    
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
            assertionFailure("NewTrackerSetupViewController.tableView: wrong indexPath")
        }
        if indexPath.row == self.tableView(tableView, numberOfRowsInSection: 0) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        return cell
    }
    
}


// MARK: - UITableViewDelegate
extension NewTrackerSetupViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            chooseCategoryTapped()
        } else if indexPath.row == 1{
            chooseScheduleTapped()
        } else {
            assertionFailure("NewTrackerSetupViewController.tableView: wrong IndexPath")
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

// MARK: - UITextFieldDelegate
extension NewTrackerSetupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


// MARK: - LayoutConstants
extension NewTrackerSetupViewController {
    enum LayoutConstants {
        static let backgroundColor: UIColor = .ypWhite
        enum Title {
            static let font: UIFont = .systemFont(ofSize: 16, weight: .medium)
            static let textColor: UIColor = .ypBlack
            static let topPadding: CGFloat = 27
        }
        enum TextField {
            static let backgroundColor: UIColor = .ypBackground
            static let font: UIFont = .systemFont(ofSize: 17, weight: .regular)
            static let textColor: UIColor = .ypBlack
            static let cornerRadius: CGFloat = 16
            static let topPadding: CGFloat = 24
            static let width: CGFloat = 343
            static let height: CGFloat = 75
            static let innerLeftPadding: CGFloat = 16
            static let innerRightPadding: CGFloat = 41
        }
        enum Buttons {
            static let cancelButtonColor: UIColor = .ypRed
            static let cancelButtonBackgroundColor: UIColor = .ypWhite
            static let cancelButtonBorderWidth: CGFloat = 1
            static let cancelButtonWidth: CGFloat = 166
            
            static let createButtonBackgroundColor: UIColor = .ypBlack
            static let createButtonTextColor: UIColor = .ypWhite
            static let createButtonDisabledColor: UIColor = .ypGray
            static let createButtonDisabledTextColor: UIColor = .white
            static let createButtonWidth: CGFloat = 161
            
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
            static let spacingToTextField: CGFloat = 24
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
extension NewTrackerSetupViewController {
    enum Strings {
        static let regularTitle = NSLocalizedString("newTrackerSetup.regular_tracker_view_title", comment: "")
        static let irregularTitle = NSLocalizedString("newTrackerSetup.irregular_tracker_view_title", comment: "")
        static let cancelButtonTitle = NSLocalizedString("newTrackerSetup.cancelButton_title", comment: "")
        static let createButtonTitle = NSLocalizedString("newTrackerSetup.createButton_title", comment: "")
        static let emojiCollectionTitle = NSLocalizedString("newTrackerSetup.emojiCollection_title", comment: "")
        static let colorCollectionTitle = NSLocalizedString("newTrackerSetup.colorCollection_title", comment: "")
        static let scheduleConfigTitle = NSLocalizedString("newTrackerSetup.Schedule_config_title", comment: "")
        static let categoryConfigTitle = NSLocalizedString("newTrackerSetup.Category_config_title", comment: "")
        static let scheduleEveryDay = NSLocalizedString("newTrackerSetup.Schedule_config_description.every_day", comment: "")
        static let textFieldPlaceholderTitle = NSLocalizedString("newTrackerSetup.textField.placeholder_title", comment: "")
    }
}
