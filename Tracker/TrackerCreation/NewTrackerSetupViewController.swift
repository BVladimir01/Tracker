//
//  NewTrackerSetupViewController.swift
//  Tracker
//
//  Created by Vladimir on 10.05.2025.
//

import UIKit


// MARK: NewTrackerSetupViewControllerDelegate
protocol NewTrackerSetupViewControllerDelegate: AnyObject {
    func newTrackerSetupViewControllerDidCreateTracker(_ vc: UIViewController)
    func newTrackerSetupViewControllerDidCancelCreation(_ vc: UIViewController)
}


// MARK: - NewTrackerSetupViewController
final class NewTrackerSetupViewController: UIViewController, ScheduleChoiceViewControllerDelegate, CategoryChoiceViewControllerDelegate {
    
    // MARK: - Internal Properties
    
    var trackerIsRegular = true
    var dataStorage: TrackerDataSource!
    weak var delegate: NewTrackerSetupViewControllerDelegate?
    
    // MARK: - Private Properties
    
    private var trackerCategory: TrackerCategory? {
        didSet {
            table.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    private var weekdays: Set<Weekday> = [] {
        didSet {
            table.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
        }
    }
    
    private let nameTextField = UITextField()
    private let cancelButton = UIButton(type: .system)
    private let createButton = UIButton(type: .system)
    private let table = UITableView()
    
    private let cellReuseID = "subtitleCell"
    
    private var shouldEnableCreateButton: Bool {
        if let trackerName = nameTextField.text, !trackerName.isEmpty,
           trackerCategory != nil,
           !weekdays.isEmpty || !trackerIsRegular {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LayoutConstants.backgroundColor
        setUpTitle()
        setUpNameTextField()
        setUpCancelButton()
        setUpCreateButton()
        setUpTable()
    }
    
    // MARK: - Interntal Methods
    
    func scheduleChoiceViewController(_ vc: UIViewController, didSelect weekdays: Set<Weekday>) {
        self.weekdays = weekdays
        updateCreateButtonState()
        vc.dismiss(animated: true)
    }
    
    func categoryChoiceViewController(_ vc: UIViewController, didDismissWith category: TrackerCategory?) {
        self.trackerCategory = category
        updateCreateButtonState()
    }
    
    // MARK: - Private Methods - Setup
    
    private func setUpTitle() {
        let title = UILabel()
        title.text = "Новый трекер"
        title.font = LayoutConstants.Title.font
        title.textColor = LayoutConstants.Title.textColor
        title.textAlignment = .center
        
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                       constant: LayoutConstants.Title.topPadding)
        ])
    }
    
    private func setUpNameTextField() {
        nameTextField.placeholder = LayoutConstants.TextField.placeHolder
        nameTextField.borderStyle = .none
        nameTextField.layer.cornerRadius = LayoutConstants.TextField.cornerRadius
        nameTextField.layer.masksToBounds = true
        nameTextField.textColor = LayoutConstants.TextField.textColor
        nameTextField.backgroundColor = LayoutConstants.TextField.backgroundColor
        nameTextField.addTarget(self, action: #selector(nameTextFieldEditingChange(_:)), for: .editingChanged)
        
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
        
        view.addSubview(nameTextField)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameTextField.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                               constant: LayoutConstants.TextField.topPadding),
            nameTextField.widthAnchor.constraint(equalToConstant: LayoutConstants.TextField.width),
            nameTextField.heightAnchor.constraint(equalToConstant: LayoutConstants.TextField.height)
        ])
    }
    
    private func setUpCancelButton() {
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(LayoutConstants.Buttons.cancelButtonColor, for: .normal)
        cancelButton.titleLabel?.font = LayoutConstants.Buttons.font
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.layer.cornerRadius = LayoutConstants.Buttons.cornerRadius
        cancelButton.layer.borderWidth = LayoutConstants.Buttons.cancelButtonBorderWidth
        cancelButton.layer.borderColor = LayoutConstants.Buttons.cancelButtonColor.cgColor
        
        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                  constant: LayoutConstants.Buttons.lateralPadding),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                 constant: LayoutConstants.Buttons.bottomPadding),
            cancelButton.widthAnchor.constraint(equalToConstant: LayoutConstants.Buttons.cancelButtonWidth),
            cancelButton.heightAnchor.constraint(equalToConstant: LayoutConstants.Buttons.height)
        ])
    }
    
    private func setUpCreateButton() {
        createButton.setTitle("Создать", for: .normal)
        createButton.backgroundColor = LayoutConstants.Buttons.createButtonBackgroundColor
        createButton.setTitleColor(LayoutConstants.Buttons.createButtonTextColor, for: .normal)
        createButton.titleLabel?.font = LayoutConstants.Buttons.font
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        createButton.layer.cornerRadius = LayoutConstants.Buttons.cornerRadius
        updateCreateButtonState()
        
        view.addSubview(createButton)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            createButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                  constant: -LayoutConstants.Buttons.lateralPadding),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                 constant: LayoutConstants.Buttons.bottomPadding),
            createButton.widthAnchor.constraint(equalToConstant: LayoutConstants.Buttons.createButtonWidth),
            createButton.heightAnchor.constraint(equalToConstant: LayoutConstants.Buttons.height)
        ])
    }
    
    private func setUpTable() {
        table.layer.masksToBounds = true
        table.layer.cornerRadius = LayoutConstants.Table.cornerRadius
        
        table.delegate = self
        table.dataSource = self
        table.rowHeight = LayoutConstants.Table.rowHeight
        table.isScrollEnabled = false
        table.separatorStyle = .singleLine
        table.separatorInset = LayoutConstants.Table.separatorInset
        table.separatorColor = LayoutConstants.Table.separatorColor
        table.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseID)
        
        view.addSubview(table)
        table.translatesAutoresizingMaskIntoConstraints = false
        let tableHeight = (trackerIsRegular ? 2 : 1)*LayoutConstants.Table.rowHeight
        NSLayoutConstraint.activate([
            table.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            table.widthAnchor.constraint(equalToConstant: LayoutConstants.Table.width),
            table.topAnchor.constraint(equalTo: nameTextField.bottomAnchor,
                                       constant: LayoutConstants.Table.spacingToTextField),
            table.heightAnchor.constraint(equalToConstant: tableHeight)
        ])
    }
    
    // MARK: - Private Methods - Helpers
    
    private func updateCreateButtonState() {
        setCreateButton(enabled: shouldEnableCreateButton)
    }
    
    private func setCreateButton(enabled: Bool) {
        let color = enabled ? LayoutConstants.Buttons.createButtonBackgroundColor : LayoutConstants.Buttons.createButtonDisabledColor
        createButton.isEnabled = enabled
        createButton.backgroundColor = color
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
        let schedule: Schedule = trackerIsRegular ? .regular(weekdays) : .irregular(Date())
        let tracker = Tracker(id: UUID(), title: trackerTitle, color: .init(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1)), emoji: "🫥", schedule: schedule)
        dataStorage.add(tracker: tracker, for: trackerCategory)
        delegate?.newTrackerSetupViewControllerDidCreateTracker(self)
    }
    
    private func chooseCategoryTapped() {
        let vc = CategoryChoiceViewController()
        vc.delegate = self
        vc.dataStorage = dataStorage
        vc.setInitialCategory(to: trackerCategory)
        present(vc, animated: true)
    }
    
    private func chooseScheduleTapped() {
        let vc = ScheduleChoiceViewController()
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
        cell.backgroundColor = LayoutConstants.Table.cellBackgroundColor
        
        cell.textLabel?.text = "Категория"
        cell.textLabel?.font = LayoutConstants.Table.cellTextFont
        cell.textLabel?.textColor = LayoutConstants.Table.cellTextColor
        
        cell.detailTextLabel?.text = trackerCategory?.title
        cell.detailTextLabel?.font = LayoutConstants.Table.cellTextFont
        cell.detailTextLabel?.textColor = LayoutConstants.Table.cellDetailTextColor
        
        cell.accessoryType = .disclosureIndicator
    }
    
    private func configureScheduleCell(_ cell: UITableViewCell) {
        cell.backgroundColor = LayoutConstants.Table.cellBackgroundColor
        
        cell.textLabel?.text = "Расписание"
        cell.textLabel?.font = LayoutConstants.Table.cellTextFont
        cell.textLabel?.textColor = LayoutConstants.Table.cellTextColor
        
        let weekdaysAsStrings = weekdays.sorted().map { $0.asString(short: true) }
        cell.detailTextLabel?.text = weekdaysAsStrings.joined(separator: ", ")
        if weekdays.count == Weekday.allCases.count {
            cell.detailTextLabel?.text = "Каждый день"
        }
        cell.detailTextLabel?.font = LayoutConstants.Table.cellTextFont
        cell.detailTextLabel?.textColor = LayoutConstants.Table.cellDetailTextColor
        
        cell.accessoryType = .disclosureIndicator
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackerIsRegular ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellReuseID)
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
            static let placeHolder = "Введите название трекера"
            static let backgroundColor: UIColor = .ypBackground
            static let font: UIFont = .systemFont(ofSize: 17, weight: .regular)
            static let textColor: UIColor = .ypBlack
            static let cornerRadius: CGFloat = 16
            static let topPadding: CGFloat = 87
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
        enum Table {
            
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
    }
}
