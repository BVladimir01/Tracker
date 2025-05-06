//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Vladimir on 01.05.2025.
//

import UIKit

class TrackerViewController: UIViewController {
    
    private var trackerCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Трекеры"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .addTracker.withTintColor(.ypBlack, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(addTrackerTapped))
        addStub()
        addDatePicker()
    }
    
    private func addStub() {
        let stubImageView = UIImageView(image: .trackerStub)
        stubImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stubImageView)
        NSLayoutConstraint.activate([
            stubImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImageView.heightAnchor.constraint(equalToConstant: LayoutConstants.stubImageHeight),
            stubImageView.widthAnchor.constraint(equalTo: stubImageView.heightAnchor, multiplier: LayoutConstants.stubImageAspectRatio),
            stubImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: LayoutConstants.stubImageTopToSuperViewTop),
            stubImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -LayoutConstants.stubImageBottomSuperViewBottom)
        ])
        
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: LayoutConstants.stubLabelFontSize, weight: LayoutConstants.stubLabelFontWeight)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: LayoutConstants.stubLabelTopToStubImageBottom)
        ])
    }
    
    private func addDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }

    @objc private func addTrackerTapped() {
        // TODO: Implement tracker addition
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let date = sender.date
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = formatter.string(from: date)
        print("today is \(formattedDate)")
    }
    
    
}


extension TrackerViewController {
    private enum LayoutConstants {
        static let stubImageHeight: CGFloat = 80
        static let stubImageAspectRatio: CGFloat = 1
        static let stubImageTopToSuperViewTop: CGFloat = 402
        static let stubImageBottomSuperViewBottom: CGFloat = 330
        
        static let stubLabelFontSize: CGFloat = 12
        static let stubLabelFontWeight: UIFont.Weight = .medium
        static let stubLabelTopToStubImageBottom: CGFloat = 8
    }
}
