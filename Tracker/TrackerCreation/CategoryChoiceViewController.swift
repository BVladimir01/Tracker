//
//  CategoryChoiceViewController.swift
//  Tracker
//
//  Created by Vladimir on 10.05.2025.
//

import UIKit


// MARK: - CategoryChoiceViewControllerDelegate
protocol CategoryChoiceViewControllerDelegate: AnyObject {
    func categoryChoiceViewController(_ vc: UIViewController, didDismissWith category: TrackerCategory?)
}


// MARK: - CategoryChoiceViewController
final class CategoryChoiceViewController: UIViewController, CategoryCreationViewControllerDelegate {
    
    // MARK: - Internal Properties
    
    var dataStorage: TrackerDataSource!
    weak var delegate: CategoryChoiceViewControllerDelegate?
    
    // MARK: - Private Properties
    
    private let stubView = UIView()
    private let addButton = UIButton(type: .system)
    private let table = UITableView()
    
    private let cellReuseID = "checkmarkCell"
    
    private var shouldDisplayStub: Bool {
        dataStorage.trackerCategories.isEmpty
    }
    private var selectedCategory: TrackerCategory?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LayoutConstants.backgroundColor
        setUpTitle()
        setUpStubView()
        setUpAddButton()
        setUpTable()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.isScrollEnabled = table.contentSize.height > LayoutConstants.Table.maxHeight
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.categoryChoiceViewController(self, didDismissWith: selectedCategory)
    }
    
    // MARK: - Internal Methods
    
    func setInitialCategory(to category: TrackerCategory?) {
        selectedCategory = category
    }
    
    func categoryCreationViewControllerDelegate(_ vc: UIViewController, didCreateCategory category: TrackerCategory) {
        table.insertRows(at: [IndexPath(row: dataStorage.trackerCategories.count - 1, section: 0)],
                         with: .automatic)
        table.reloadRows(at: [IndexPath(row: dataStorage.trackerCategories.count - 2, section: 0)],
                         with: .none)
        table.selectRow(at: IndexPath(row: dataStorage.trackerCategories.count - 1, section: 0),
                        animated: true,
                        scrollPosition: .bottom)
        tableView(table, didSelectRowAt: IndexPath(row: dataStorage.trackerCategories.count - 1, section: 0))
        replaceStubView()
        vc.dismiss(animated: true)
    }
    
    // MARK: - Private Methods - Setup
    
    private func setUpTitle() {
        let title = UILabel()
        title.text = "Категория"
        title.font = LayoutConstants.Title.font
        title.textColor = LayoutConstants.Title.textColor
        title.textAlignment = .center
        
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                       constant: LayoutConstants.Title.spacingToSuperViewTop)
        ])
    }
    
    private func setUpStubView() {
        let stubImageView = UIImageView(image: .trackerStub)
        stubImageView.translatesAutoresizingMaskIntoConstraints = false
        stubView.addSubview(stubImageView)
        NSLayoutConstraint.activate([
            stubImageView.centerXAnchor.constraint(equalTo: stubView.centerXAnchor),
            stubImageView.heightAnchor.constraint(equalToConstant: LayoutConstants.Stub.imageHeight),
            stubImageView.widthAnchor.constraint(equalToConstant: LayoutConstants.Stub.imageWidth),
            stubImageView.topAnchor.constraint(equalTo: stubView.topAnchor, constant: LayoutConstants.Stub.imageSpacingToSuperViewTop),
        ])
        
        let label = UILabel()
        label.text = "Привычки и события можно" + "\n" + "объединить по смыслу"
        label.textAlignment = .center
        label.font = LayoutConstants.Stub.labelFont
        label.textColor = LayoutConstants.Stub.textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        stubView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: stubView.centerXAnchor),
            label.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: LayoutConstants.Stub.labelToImageSpacing)
        ])
        
        stubView.backgroundColor = .ypWhite
        stubView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stubView)
        NSLayoutConstraint.activate([
            stubView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                          constant: LayoutConstants.Stub.stubViewToSuperViewSpacing),
            stubView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stubView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stubView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        replaceStubView()
    }
    
    private func setUpAddButton() {
        addButton.setTitle("Добавить категорию", for: .normal)
        addButton.titleLabel?.font = LayoutConstants.Button.font
        addButton.setTitleColor(LayoutConstants.Button.textColor, for: .normal)
        addButton.backgroundColor = LayoutConstants.Button.backgroundColor
        addButton.layer.cornerRadius = LayoutConstants.Button.cornerRadius
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                               constant: -LayoutConstants.Button.spacingToSuperviewBottom),
            addButton.widthAnchor.constraint(equalToConstant: LayoutConstants.Button.width),
            addButton.heightAnchor.constraint(equalToConstant: LayoutConstants.Button.height)
        ])
    }
    
    private func setUpTable() {
        table.dataSource = self
        table.delegate = self
        table.isScrollEnabled = false
        table.backgroundColor = .clear
        table.rowHeight = LayoutConstants.Table.rowHeight
        table.separatorStyle = .singleLine
        table.separatorInset = LayoutConstants.Table.separatorInset
        table.separatorColor = LayoutConstants.Table.separatorColor
        table.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseID)
        
        view.addSubview(table)
        table.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            table.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            table.widthAnchor.constraint(equalToConstant: LayoutConstants.Table.width),
            table.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                       constant: LayoutConstants.Table.spacingToSuperviewTop),
            table.heightAnchor.constraint(lessThanOrEqualToConstant: LayoutConstants.Table.maxHeight)
        ])
    }
    
    // MARK: - Private Methods - Helpers
    
    private func replaceStubView() {
        stubView.isHidden = !shouldDisplayStub
    }
    
    // MARK: - Private Methods - Intentions
    
    @objc
    private func addButtonTapped() {
        // TODO: - Implement button tap
        let vc = CategoryCreationViewController()
        vc.dataStorage = dataStorage
        vc.delegate = self
        present(vc, animated: true)
    }
    
}


// MARK: - UITableViewDataSource
extension CategoryChoiceViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataStorage.trackerCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = dataStorage.trackerCategories[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath)
        cell.backgroundColor = LayoutConstants.Table.cellBackgroundColor
        cell.textLabel?.text = category.title
        cell.textLabel?.font = LayoutConstants.Table.cellTextFont
        cell.textLabel?.textColor = LayoutConstants.Table.cellTextColor
        cell.layer.masksToBounds = true
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell.layer.cornerRadius = LayoutConstants.Table.cornerRadius
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if indexPath.row == 0 {
            cell.layer.cornerRadius = LayoutConstants.Table.cornerRadius
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            cell.layer.cornerRadius = .zero
        }
        cell.accessoryType = (category == selectedCategory) ? .checkmark : .none
        cell.selectedBackgroundView?.layer.masksToBounds = true
        cell.selectedBackgroundView?.layer.cornerRadius = LayoutConstants.Table.cornerRadius
        return cell
    }
    
    
}


// MARK: - UITableViewDelegate
extension CategoryChoiceViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let oldSelectedRow: Int?
        let newSelectedRow = indexPath.row
        if let selectedCategory,
            let idOfSelectedCategory = dataStorage.trackerCategories.firstIndex(of: selectedCategory) {
            oldSelectedRow = idOfSelectedCategory
        } else {
            oldSelectedRow = nil
        }
        if newSelectedRow == oldSelectedRow {
            selectedCategory = nil
        } else {
            selectedCategory = dataStorage.trackerCategories[newSelectedRow]
        }
        if let oldSelectedRow {
            tableView.reloadRows(at: [IndexPath(row: oldSelectedRow, section: 0)], with: .none)
        }
        tableView.reloadRows(at: [IndexPath(row: newSelectedRow, section: 0)], with: .none)
        tableView.deselectRow(at: IndexPath(row: newSelectedRow, section: 0), animated: false)
    }
}


// MARK: - LayoutConstants
extension CategoryChoiceViewController {
    enum LayoutConstants {
        static let backgroundColor: UIColor = .ypWhite
        enum Title {
            static let font: UIFont = .systemFont(ofSize: 16, weight: .medium)
            static let textColor: UIColor = .ypBlack
            static let spacingToSuperViewTop: CGFloat = 27
        }
        enum Stub {
            static let imageHeight: CGFloat = 80
            static let imageWidth: CGFloat = 80
            static let imageSpacingToSuperViewTop: CGFloat = 246
            
            static let labelFont: UIFont = .systemFont(ofSize: 12, weight: .medium)
            static let textColor: UIColor = .ypBlack
            static let labelToImageSpacing: CGFloat = 8
            
            static let backgroundColor: UIColor = .ypWhite
            static let stubViewToSuperViewSpacing: CGFloat = 49
        }
        enum Button {
            static let backgroundColor: UIColor = .ypBlack
            static let font: UIFont = .systemFont(ofSize: 16, weight: .medium)
            static let textColor: UIColor = .ypWhite
            static let cornerRadius: CGFloat = 16
            static let spacingToSuperviewBottom: CGFloat = 16
            static let height: CGFloat = 60
            static let width: CGFloat = 335
        }
        enum Table {
            static let cornerRadius: CGFloat = 16
            static let rowHeight: CGFloat = 75
            static let width: CGFloat = 343
            static let maxHeight: CGFloat = 525
            static let spacingToSuperviewTop: CGFloat = 87
            static let separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            static let separatorColor: UIColor = .gray
            
            static let cellTextFont: UIFont = .systemFont(ofSize: 17, weight: .regular)
            static let cellTextColor: UIColor = .ypBlack
            static let cellBackgroundColor: UIColor = .ypBackground
        }
    }
}
