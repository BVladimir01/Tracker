//
//  CategoryChoiceViewController.swift
//  Tracker
//
//  Created by Vladimir on 10.05.2025.
//

import UIKit


// MARK: - CategoryChoiceViewController
final class CategoryChoiceViewController: UIViewController {
    
    // MARK: - Private Properties
    private let stubView = UIView()
    private let addButton = UIButton(type: .system)
    private let dataStorage: TrackerDataStore = TrackerDataStore.shared
    
    private var shouldDisplayStub: Bool {
        dataStorage.trackerCategories.isEmpty
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setUpTitle()
        setUpStubView()
        setUpAddButton()
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
                                       constant: LayoutConstants.Title.topPadding)
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
            stubImageView.topAnchor.constraint(equalTo: stubView.topAnchor, constant: LayoutConstants.Stub.imageTopPadding),
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
            label.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: LayoutConstants.Stub.labelTopToStubImageBottom)
        ])
        
        stubView.backgroundColor = .ypWhite
        stubView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stubView)
        NSLayoutConstraint.activate([
            stubView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                          constant: LayoutConstants.Stub.stubViewTopPadding),
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
                                               constant: -LayoutConstants.Button.bottomPadding),
            addButton.widthAnchor.constraint(equalToConstant: LayoutConstants.Button.width),
            addButton.heightAnchor.constraint(equalToConstant: LayoutConstants.Button.height)
        ])
    }
    
    // MARK: - Private Methods - Helpers
    
    private func replaceStubView() {
        if shouldDisplayStub {
            view.bringSubviewToFront(stubView)
            stubView.alpha = 1
        } else {
            view.sendSubviewToBack(stubView)
            stubView.alpha = 0
        }
    }
    
    // MARK: - Private Methods - Intentions
    
    @objc
    private func addButtonTapped() {
        // TODO: - Implement button tap
    }
    
}




// MARK: - LayoutConstants
extension CategoryChoiceViewController {
    enum LayoutConstants {
        enum Title {
            static let font: UIFont = .systemFont(ofSize: 16, weight: .medium)
            static let textColor: UIColor = .ypBlack
            static let topPadding: CGFloat = 27
        }
        enum Stub {
            static let imageHeight: CGFloat = 80
            static let imageWidth: CGFloat = 80
            static let imageTopPadding: CGFloat = 246
            
            static let labelFont: UIFont = .systemFont(ofSize: 12, weight: .medium)
            static let textColor: UIColor = .ypBlack
            static let labelTopToStubImageBottom: CGFloat = 8
            
            static let backgroundColor: UIColor = .ypWhite
            static let stubViewTopPadding: CGFloat = 49
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
