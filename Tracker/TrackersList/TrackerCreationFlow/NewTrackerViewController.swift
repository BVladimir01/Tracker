//
//  NewTrackerTypeViewController.swift
//  Tracker
//
//  Created by Vladimir on 10.05.2025.
//

import UIKit

// MARK: NewTrackerViewControllerDelegate
protocol NewTrackerViewControllerDelegate: AnyObject {
    func newTrackerViewController(_ vc: UIViewController, didCreateTracker tracker: Tracker)
    func newTrackerViewControllerDidCancelCreation(_ vc: UIViewController)
}


// MARK: - NewTracerViewController
final class NewTrackerViewController: UIViewController, NewTrackerSetupViewControllerDelegate {
    
    // MARK: - Private Properties
    
    private weak var delegate: NewTrackerViewControllerDelegate?
    private var selectedDate: Date
    private var categoryStore: CategoryStoreProtocol
    
    private let regularTrackerButton = UIButton(type: .system)
    private let irregularTrackerButton = UIButton(type: .system)
    
    // MARK: Initializers
    
    init(delegate: NewTrackerViewControllerDelegate, selectedDate: Date, categoryStore: CategoryStoreProtocol) {
        self.delegate = delegate
        self.selectedDate = selectedDate
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
        setUpRegularTrackerButton()
        setUpIrregularTrackerButton()
    }
    
    // MARK: - Internal Methods
    
    func newTrackerSetupViewController(_ vc: UIViewController, didCreateTracker tracker: Tracker) {
        vc.dismiss(animated: true)
        delegate?.newTrackerViewController(self, didCreateTracker: tracker)
    }
    
    func newTrackerSetupViewControllerDidCancelCreation(_ vc: UIViewController) {
        vc.dismiss(animated: false)
        delegate?.newTrackerViewControllerDidCancelCreation(self)
    }
    
    // MARK: - Private Methods - Setup
    
    private func setUpTitle() {
        let title = UILabel()
        title.text = Strings.title
        title.font = LayoutConstants.Title.Font
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
    
    private func setUpRegularTrackerButton() {
        regularTrackerButton.setTitle(Strings.regularTrackerTitle, for: .normal)
        regularTrackerButton.setTitleColor(LayoutConstants.Buttons.textColor, for: .normal)
        regularTrackerButton.titleLabel?.font = LayoutConstants.Buttons.titleFont
        regularTrackerButton.addTarget(self, action: #selector(didSelectTrackerType(_:)), for: .touchUpInside)
        
        regularTrackerButton.layer.cornerRadius = LayoutConstants.Buttons.cornerRadius
        regularTrackerButton.backgroundColor = LayoutConstants.Buttons.backgroundColor
        
        view.addSubview(regularTrackerButton)
        regularTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            regularTrackerButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            regularTrackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                      constant: LayoutConstants.Buttons.topButtonToSuperviewTop),
            regularTrackerButton.heightAnchor.constraint(equalToConstant: LayoutConstants.Buttons.height),
            regularTrackerButton.widthAnchor.constraint(equalToConstant: LayoutConstants.Buttons.width)
        ])
        
    }
    
    private func setUpIrregularTrackerButton() {
        irregularTrackerButton.setTitle(Strings.irregularTrackerTitle, for: .normal)
        irregularTrackerButton.setTitleColor(LayoutConstants.Buttons.textColor, for: .normal)
        irregularTrackerButton.titleLabel?.font = LayoutConstants.Buttons.titleFont
        irregularTrackerButton.addTarget(self, action: #selector(didSelectTrackerType(_:)), for: .touchUpInside)
        
        irregularTrackerButton.layer.cornerRadius = LayoutConstants.Buttons.cornerRadius
        irregularTrackerButton.backgroundColor = LayoutConstants.Buttons.backgroundColor
        
        view.addSubview(irregularTrackerButton)
        irregularTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            irregularTrackerButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            irregularTrackerButton.topAnchor.constraint(equalTo: regularTrackerButton.bottomAnchor,
                                                        constant: LayoutConstants.Buttons.buttonsSpacing),
            irregularTrackerButton.heightAnchor.constraint(equalToConstant: LayoutConstants.Buttons.height),
            irregularTrackerButton.widthAnchor.constraint(equalToConstant: LayoutConstants.Buttons.width)
        ])
    }
    
    // MARK: - Private Methods - Intentions
    
    @objc private func didSelectTrackerType(_ sender: UIButton) {
        guard let buttonTitle = sender.title(for: .normal) else {
            assertionFailure("NewTrackerViewController.didTapCreate: Failed to get title of the button")
            return
        }
        var createRegularTracker: Bool
        if buttonTitle == Strings.regularTrackerTitle {
            createRegularTracker = true
        } else if buttonTitle == Strings.irregularTrackerTitle {
            createRegularTracker = false
        } else {
            assertionFailure("NewTrackerViewController.didTapCreate: unknown title")
            return
        }
        let newTrackerSetupVC = NewTrackerSetupViewController(trackerIsRegular: createRegularTracker, categoryStore: categoryStore, selectedDate: selectedDate, delegate: self)
        present(newTrackerSetupVC, animated: true)
    }
    
}


// MARK: - LayoutConstants
extension NewTrackerViewController {
    enum LayoutConstants {
        static let backgroundColor: UIColor = .ypWhite
        enum Title {
            static let Font: UIFont = .systemFont(ofSize: 16, weight: .medium)
            static let textColor: UIColor = .ypBlack
            static let spacingToSuperviewTop: CGFloat = 27
        }
        enum Buttons {
            static let titleFont: UIFont = .systemFont(ofSize: 16, weight: .medium)
            static let backgroundColor: UIColor = .ypBlack
            static let textColor: UIColor = .ypWhite
            static let width: CGFloat = 335
            static let height: CGFloat = 60
            static let cornerRadius: CGFloat = 16
            
            static let topButtonToSuperviewTop: CGFloat = 344
            static let buttonsSpacing: CGFloat = 16
        }
    }
}


// MARK: - Strings
extension NewTrackerViewController {
    enum Strings {
        static let regularTrackerTitle = NSLocalizedString("trackerCreation.regular_tracker_title", comment: "")
        static let irregularTrackerTitle = NSLocalizedString("trackerCreation.irregular_tracker_title", comment: "")
        static let title = NSLocalizedString("trackerCreation.view_title", comment: "")
    }
}
