//
//  TrackersFiltersViewController.swift
//  Tracker
//
//  Created by Vladimir on 18.06.2025.
//

import UIKit


// MARK: - FilterSelectorViewControllerDelegate
protocol FilterSelectorViewControllerDelegate: AnyObject {
    func filterSelector(_ vc: UIViewController, didSelect filter: TrackersListFilter)
}


// MARK: - FilterSelectorViewController
final class FilterSelectorViewController: UIViewController {
    
    private weak var delegate: FilterSelectorViewControllerDelegate?
    private var activeFilter: TrackersListFilter
    private let table = UITableView()
    private let titleLabel = UILabel()
    private let cellID = "filterCell"
    private let filters = TrackersListFilter.allCases
    
    init(delegate: FilterSelectorViewControllerDelegate, activeFilter: TrackersListFilter) {
        self.delegate = delegate
        self.activeFilter = activeFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setUpView()
        setUpTitle()
        setUpTable()
    }
    
    private func addSubviews() {
        [table, titleLabel].forEach { view.addSubview($0) }
    }
    
    private func setUpTitle() {
        titleLabel.text = Strings.title
        titleLabel.font = LayoutConstants.Title.font
        titleLabel.textColor = LayoutConstants.Title.textColor
        titleLabel.textAlignment = .center
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                       constant: LayoutConstants.Title.spacingToTopView)
        ])
    }
    
    private func setUpTable() {
        table.dataSource = self
        table.delegate = self
        table.isScrollEnabled = false
        table.backgroundColor = .clear
        table.rowHeight = LayoutConstants.Table.rowHeight
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: cellID)
        table.separatorStyle = .singleLine
        table.layer.masksToBounds = true
        table.layer.cornerRadius = LayoutConstants.Table.cornerRadius
        
        table.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            table.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            table.widthAnchor.constraint(equalToConstant: LayoutConstants.Table.width),
            table.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                       constant: LayoutConstants.Table.spacingToTopView),
            table.heightAnchor.constraint(lessThanOrEqualToConstant: LayoutConstants.Table.height)
        ])
    }
    
    private func setUpView() {
        view.backgroundColor = LayoutConstants.backgroundColor
    }
    
}


// MARK: - UITableViewDataSource
extension FilterSelectorViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let filter = filters[indexPath.row]
        if filter == activeFilter {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.textLabel?.text = filter.asString
        cell.textLabel?.textColor = LayoutConstants.Cell.textColor
        cell.textLabel?.font = LayoutConstants.Cell.textFont
        cell.backgroundColor = LayoutConstants.Cell.backgroundColor
        cell.separatorInset = LayoutConstants.Cell.separatorInset
        return cell
    }
    
}


// MARK: - UITableViewDelegate
extension FilterSelectorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.filterSelector(self, didSelect: filters[indexPath.row])
    }
}


// MARK: - LayoutConstants
extension FilterSelectorViewController {
    enum LayoutConstants {
        static let backgroundColor: UIColor = .ypWhite
        enum Title {
            static let font: UIFont = .systemFont(ofSize: 16, weight: .medium)
            static let textColor: UIColor = .ypBlack
            static let spacingToTopView: CGFloat = 27
        }
        enum Table {
            static let cornerRadius: CGFloat = 16
            static let rowHeight: CGFloat = 75
            static let width: CGFloat = 343
            static let height: CGFloat = 300
            static let spacingToTopView: CGFloat = 38
        }
        enum Cell {
            static let textFont: UIFont = .systemFont(ofSize: 17, weight: .regular)
            static let textColor: UIColor = .ypBlack
            static let backgroundColor: UIColor = .ypBackground
            static let separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}


// MARK: - Strings
extension FilterSelectorViewController {
    enum Strings {
        static let title = NSLocalizedString("trackerFilter.filters", comment: "")
    }
}
