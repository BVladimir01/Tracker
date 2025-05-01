//
//  StatsViewController.swift
//  Tracker
//
//  Created by Vladimir on 01.05.2025.
//

import UIKit

class StatsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Статистика"
        addStub()
    }
    
    private func addStub() {
        let stubImageView = UIImageView(image: .statsStub)
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
        label.text = "Анализировать пока нечего"
        label.font = UIFont.systemFont(ofSize: LayoutConstants.stubLabelFontSize, weight: LayoutConstants.stubLabelFontWeight)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: LayoutConstants.stubLabelTopToStubImageBottom)
        ])
    }

}


extension StatsViewController {
    private enum LayoutConstants {
        static let stubImageHeight: CGFloat = 80
        static let stubImageAspectRatio: CGFloat = 1
        static let stubImageTopToSuperViewTop: CGFloat = 375
        static let stubImageBottomSuperViewBottom: CGFloat = 357
        
        static let stubLabelFontSize: CGFloat = 12
        static let stubLabelFontWeight: UIFont.Weight = .medium
        static let stubLabelTopToStubImageBottom: CGFloat = 8
    }
}
