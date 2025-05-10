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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setUpTitle()
        setUpDoneButton()
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
    
    // MARK: - Private Methods - Intentions
    
    @objc
    private func doneButtonTapped() {
        // TODO: implement button tap
    }
    
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
    }
}
