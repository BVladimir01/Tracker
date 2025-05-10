//
//  ScheduleChoiceViewController.swift
//  Tracker
//
//  Created by Vladimir on 10.05.2025.
//

import UIKit


// MARK: - ScheduleChoiceViewController
final class ScheduleChoiceViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let doneButton = UIButton(type: .system)
    private let table = UITableView()
    
    private let cellReuseID = "switcherCell"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
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
                                       constant: LayoutConstants.Title.topPadding)
        ])
    }
    
    private func setUpDoneButton() {
        doneButton.setTitle("Готово", for: .normal)
        doneButton.titleLabel?.font = LayoutConstants.Button.font
        doneButton.setTitleColor(LayoutConstants.Button.textColor, for: .normal)
        doneButton.backgroundColor = LayoutConstants.Button.backgroundColor
        doneButton.layer.cornerRadius = LayoutConstants.Button.cornerRadius
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        
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
        let tableHeight = CGFloat(Weekday.allCases.count)*LayoutConstants.Table.rowHeight - 0.5
        NSLayoutConstraint.activate([
            table.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            table.widthAnchor.constraint(equalToConstant: LayoutConstants.Table.width),
            table.bottomAnchor.constraint(equalTo: doneButton.topAnchor,
                                       constant: -LayoutConstants.Table.spacingToButton),
            table.heightAnchor.constraint(equalToConstant: tableHeight)
        ])
    }
    
    // MARK: - Private Methods - Intentions
    
    @objc
    private func doneButtonTapped() {
        // TODO: implement button tap
    }

}


// MARK: - UITableViewDataSource
extension ScheduleChoiceViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Weekday.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath)
        cell.backgroundColor = LayoutConstants.Table.cellBackgroundColor
        cell.textLabel?.text = Weekday.week[indexPath.row].asString(short: false)
        cell.textLabel?.font = LayoutConstants.Table.cellTextFont
        cell.textLabel?.textColor = LayoutConstants.Table.cellTextColor
        let switcher = UISwitch()
        switcher.onTintColor = .ypBlue
        cell.accessoryView = switcher
        return cell
    }
    
    
}


// MARK: - UITableViewDelegate
extension ScheduleChoiceViewController: UITableViewDelegate {
    
}


// MARK: - LayoutConstants
extension ScheduleChoiceViewController {
    enum LayoutConstants {
        enum Title {
            static let font: UIFont = .systemFont(ofSize: 16, weight: .medium)
            static let textColor: UIColor = .ypBlack
            static let topPadding: CGFloat = 27
        }
        enum Button {
            static let backgroundColor: UIColor = .ypBlack
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
            static let spacingToButton: CGFloat = 39
            static let separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            static let separatorColor: UIColor = .gray
            
            static let cellTextFont: UIFont = .systemFont(ofSize: 17, weight: .regular)
            static let cellTextColor: UIColor = .ypBlack
            static let cellBackgroundColor: UIColor = .ypBackground
        }
    }
}
