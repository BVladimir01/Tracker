//
//  CategorySelectionViewController.swift
//  Tracker
//
//  Created by Vladimir on 10.05.2025.
//

import UIKit


// MARK: - CategorySelectionViewControllerDelegate
protocol CategorySelectionViewControllerDelegate: AnyObject {
    func categorySelectionViewController(_ vc: UIViewController, didDismissWith category: TrackerCategory?)
}


// MARK: - CategorySelectionViewController
final class CategorySelectionViewController: UIViewController, CategoryCreationViewControllerDelegate {
    
    // MARK: - Private Properties

    private weak var delegate: CategorySelectionViewControllerDelegate?
    private let viewModel: CategorySelectionViewModel
    private let categoryStore: CategoryStore
    
    private let stubView = UIView()
    private let addButton = UIButton(type: .system)
    private let table = UITableView()
    
    private let cellReuseID = "checkmarkCell"
    
    private var tableShouldScroll: Bool {
        table.contentSize.height > LayoutConstants.Table.maxHeight
    }
    
    init(delegate: CategorySelectionViewControllerDelegate, categoryStore: CategoryStore, viewModel: CategorySelectionViewModel) {
        self.delegate = delegate
        self.viewModel = viewModel
        self.categoryStore = categoryStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init not implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LayoutConstants.backgroundColor
        setUpTitle()
        setUpStubView()
        setUpAddButton()
        setUpTable()
        updateTableViewState()
        setUpViewModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let selectedCategory = viewModel.selectedCategory else {
            return
        }
        delegate?.categorySelectionViewController(self, didDismissWith: selectedCategory)
    }
    
    // MARK: - Internal Methods
    
    func categoryCreationViewControllerDelegate(_ vc: UIViewController, didCreateCategory category: TrackerCategory) {
        viewModel.addCategory(category)
        viewModel.setSelectedCategory(to: category)
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
    
    private func setUpViewModel() {
        viewModel.onCategoriesChange = { [weak self] categories in
            guard let self else { return }
            self.table.reloadData()
            self.setStubView(hidden: !self.viewModel.shouldDisplayStub)
            self.updateTableViewState()
        }
        viewModel.onSelectedRowChange = { [weak self] rows in
            let (oldRow, newRow) = rows
            if let oldRow {
                self?.table.reloadRows(at: [IndexPath(row: oldRow, section: 0)],
                                       with: .none)
            }
            if let newRow {
                self?.table.reloadRows(at: [IndexPath(row: newRow, section: 0)],
                                       with: .none)
                self?.table.scrollToRow(at: IndexPath(row: newRow, section: 0),
                                        at: .middle,
                                        animated: true)
            }
        }
    }
    
    // MARK: - Private Methods - Helpers
    
    private func setStubView(hidden: Bool) {
        stubView.isHidden = hidden
    }
    
    private func updateTableViewState() {
        table.isScrollEnabled = tableShouldScroll
    }
    
    private func configureCell(_ cell: UITableViewCell, with cellModel: CategorySelectionCellModel) {
        cell.backgroundColor = cellModel.backgroundColor
        cell.textLabel?.text = cellModel.text
        cell.textLabel?.font = cellModel.textFont
        cell.textLabel?.textColor = cellModel.textColor
        cell.accessoryType = cellModel.isSelected ? .checkmark : .none
        cell.layer.cornerRadius = cellModel.cornerRadius
        cell.layer.masksToBounds = true
        cell.selectedBackgroundView?.layer.cornerRadius = cellModel.cornerRadius
        cell.selectedBackgroundView?.layer.masksToBounds = true
        switch (cellModel.isFirst, cellModel.isLast) {
        case (true, true):
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        case (true, false):
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.selectedBackgroundView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case (false, true):
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.selectedBackgroundView?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        case (false, false):
            cell.layer.masksToBounds = false
            cell.layer.cornerRadius = 0
        }
    }
    
    // MARK: - Private Methods - Intentions
    
    @objc
    private func addButtonTapped() {
        let vc = CategoryCreationViewController(categoryStore: categoryStore, delegate: self)
        present(vc, animated: true)
    }
    
}


// MARK: - UITableViewDataSource
extension CategorySelectionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath)
        let category = viewModel.categories[indexPath.row]
        let isSelected: Bool
        if let selectedRow = viewModel.selectedRow,  indexPath.row == selectedRow{
            isSelected = true
        } else {
            isSelected = false
        }
        let isLast = indexPath.row == (tableView.numberOfRows(inSection: indexPath.section) - 1)
        let cellModel = CategorySelectionCellModel(isFirst: indexPath.row == 0,
                                                   isLast: isLast,
                                                   isSelected: isSelected,
                                                   text: category.title,
                                                   textFont: LayoutConstants.Table.cellTextFont,
                                                   textColor: LayoutConstants.Table.cellTextColor,
                                                   cornerRadius: LayoutConstants.Table.cornerRadius,
                                                   backgroundColor: LayoutConstants.Table.cellBackgroundColor)
        configureCell(cell, with: cellModel)
        return cell
    }
    
}


// MARK: - UITableViewDelegate
extension CategorySelectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedRow = indexPath.row
    }
    
}


// MARK: - LayoutConstants
extension CategorySelectionViewController {
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
