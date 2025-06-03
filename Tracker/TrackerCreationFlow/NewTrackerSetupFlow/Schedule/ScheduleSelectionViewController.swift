//
//  ScheduleSelectionViewController.swift
//  Tracker
//
//  Created by Vladimir on 10.05.2025.
//

import UIKit


// MARK: - ScheduleSelectionViewControllerDelegate
protocol ScheduleSelectionViewControllerDelegate: AnyObject {
    func scheduleSelectionViewController(_ vc: UIViewController, didSelect weekdays: Set<Weekday>)
}


// MARK: - ScheduleSelectionViewController
final class ScheduleSelectionViewController: UIViewController {
    
    // MARK: - Internal Properties
    
    weak var delegate: ScheduleSelectionViewControllerDelegate?
    var initialWeekdays: Set<Weekday> = []
    
    // MARK: - Private Properties
    
    private let doneButton = UIButton(type: .system)
    private let table = UITableView()
    
    private let cellReuseID = "switcherCell"
    
    private var shouldEnableDoneButton: Bool {
        for i in 0..<Weekday.allCases.count {
            let indexPath = IndexPath(row: i, section: 0)
            if let cell = table.cellForRow(at: indexPath),
                let switcher = cell.accessoryView as? UISwitch,
                switcher.isOn {
                return true
            }
        }
        return false
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LayoutConstants.backgroundColor
        setUpTitle()
        setUpDoneButton()
        setUpTable()
    }
    
    // MARK: - Private Methods - Setup
    
    private func setUpTitle() {
        let title = UILabel()
        title.text = "Расписание"
        title.font = LayoutConstants.Title.font
        title.textColor = LayoutConstants.Title.textColor
        title.textAlignment = .center
        
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                       constant: LayoutConstants.Title.spacingToSuperviewTop)
        ])
    }
    
    private func setUpDoneButton() {
        doneButton.setTitle("Готово", for: .normal)
        doneButton.titleLabel?.font = LayoutConstants.Button.font
        doneButton.setTitleColor(LayoutConstants.Button.textColor, for: .normal)
        doneButton.backgroundColor = LayoutConstants.Button.backgroundColor
        doneButton.layer.cornerRadius = LayoutConstants.Button.cornerRadius
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        if !initialWeekdays.isEmpty { setDoneButton(enabled: true) }
        
        view.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            doneButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                               constant: -LayoutConstants.Button.bottomPadding),
            doneButton.widthAnchor.constraint(equalToConstant: LayoutConstants.Button.width),
            doneButton.heightAnchor.constraint(equalToConstant: LayoutConstants.Button.height)
        ])
    }
    
    private func setUpTable() {
        table.layer.masksToBounds = true
        table.layer.cornerRadius = LayoutConstants.Table.cornerRadius
        
        table.dataSource = self
        table.rowHeight = LayoutConstants.Table.rowHeight
        table.isScrollEnabled = false
        table.separatorStyle = .singleLine
        table.separatorInset = LayoutConstants.Table.separatorInset
        table.separatorColor = LayoutConstants.Table.separatorColor
        table.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseID)
        table.allowsSelection = false
        
        view.addSubview(table)
        table.translatesAutoresizingMaskIntoConstraints = false
        let tableHeight = CGFloat(Weekday.allCases.count)*LayoutConstants.Table.rowHeight
        NSLayoutConstraint.activate([
            table.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            table.widthAnchor.constraint(equalToConstant: LayoutConstants.Table.width),
            table.bottomAnchor.constraint(equalTo: doneButton.topAnchor,
                                       constant: -LayoutConstants.Table.spacingToButton),
            table.heightAnchor.constraint(equalToConstant: tableHeight)
        ])
    }
    
    // MARK: - Private Methods - Helpers
    
    private func updateDoneButtonState() {
        setDoneButton(enabled: shouldEnableDoneButton)
    }
    
    private func setDoneButton(enabled: Bool) {
        doneButton.isEnabled = enabled
        doneButton.backgroundColor = enabled ? LayoutConstants.Button.backgroundColor : LayoutConstants.Button.disabledBackgroundColor
    }
    
    // MARK: - Private Methods - Intentions
    
    @objc
    private func doneButtonTapped() {
        var selectedWeekdays: Set<Weekday> = []
        for i in 0..<Weekday.allCases.count {
            let indexPath = IndexPath(row: i, section: 0)
            let cell = table.cellForRow(at: indexPath)
            if let switcher = cell?.accessoryView as? UISwitch, switcher.isOn, let weekday = Weekday(rawValue: i) {
                selectedWeekdays.insert(weekday)
            }
        }
        delegate?.scheduleSelectionViewController(self, didSelect: selectedWeekdays)
    }
    
    @objc
    private func switcherToggled(_ sender: UISwitch) {
        updateDoneButtonState()
    }

}


// MARK: - UITableViewDataSource
extension ScheduleSelectionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Weekday.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath)
        guard let weekday = Weekday(rawValue: indexPath.row) else {
            assertionFailure("ScheduleSelectionViewController.tableView: Failed to create weekday from indexPath")
            return cell
        }
        cell.backgroundColor = LayoutConstants.Table.cellBackgroundColor
        if let weekday = Weekday(rawValue: indexPath.row) {
            cell.textLabel?.text = weekday.asString(short: false)
        }
        cell.textLabel?.font = LayoutConstants.Table.cellTextFont
        cell.textLabel?.textColor = LayoutConstants.Table.cellTextColor
        if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        // This will only be called once when cells are created
        // Cells will not be reused (dequeued)
        let switcher = UISwitch()
        if initialWeekdays.contains(weekday) {
            switcher.setOn(true, animated: true)
        }
        switcher.onTintColor = LayoutConstants.Table.cellSwitcherOnColor
        switcher.addTarget(self, action: #selector(switcherToggled(_:)), for: .valueChanged)
        cell.accessoryView = switcher
        return cell
    }
    
}


// MARK: - LayoutConstants
extension ScheduleSelectionViewController {
    enum LayoutConstants {
        static let backgroundColor: UIColor = .ypWhite
        enum Title {
            static let font: UIFont = .systemFont(ofSize: 16, weight: .medium)
            static let textColor: UIColor = .ypBlack
            static let spacingToSuperviewTop: CGFloat = 27
        }
        enum Button {
            static let backgroundColor: UIColor = .ypBlack
            static let disabledBackgroundColor: UIColor = .ypGray
            static let font: UIFont = .systemFont(ofSize: 16, weight: .medium)
            static let textColor: UIColor = .ypWhite
            static let cornerRadius: CGFloat = 16
            static let bottomPadding: CGFloat = 16
            static let height: CGFloat = 60
            static let width: CGFloat = 335
        }
        enum Table {
            static let cornerRadius: CGFloat = 16
            static let rowHeight: CGFloat = 75
            static let width: CGFloat = 343
            static let spacingToButton: CGFloat = 47
            static let separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            static let separatorColor: UIColor = .gray
            
            static let cellTextFont: UIFont = .systemFont(ofSize: 17, weight: .regular)
            static let cellTextColor: UIColor = .ypBlack
            static let cellBackgroundColor: UIColor = .ypBackground
            static let cellSwitcherOnColor: UIColor = .ypBlue
        }
    }
}
