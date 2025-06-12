//
//  StatsViewController.swift
//  Tracker
//
//  Created by Vladimir on 01.05.2025.
//

import UIKit


final class StatsViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let stubView = UIView()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.title
        setUpStub()
    }
    
    // MARK: - Private Methods
    
    private func setUpStub() {
        let stubImageView = UIImageView(image: .statsStub)
        stubImageView.translatesAutoresizingMaskIntoConstraints = false
        stubView.addSubview(stubImageView)
        NSLayoutConstraint.activate([
            stubImageView.centerXAnchor.constraint(equalTo: stubView.centerXAnchor),
            stubImageView.heightAnchor.constraint(equalToConstant: LayoutConstants.Stub.imageHeight),
            stubImageView.widthAnchor.constraint(equalToConstant: LayoutConstants.Stub.imageWidth),
            stubImageView.topAnchor.constraint(equalTo: stubView.topAnchor, constant: LayoutConstants.Stub.imageTopPadding)
        ])
        
        let label = UILabel()
        label.text = Strings.stubViewTitle
        label.font = LayoutConstants.Stub.labelFont
        label.textColor = LayoutConstants.Stub.textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        stubView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: stubView.centerXAnchor),
            label.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: LayoutConstants.Stub.labelToImageSpacing)
        ])
        
        stubView.backgroundColor = .ypWhite
        stubView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stubView)
        NSLayoutConstraint.activate([
            stubView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stubView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stubView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stubView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

}


// MARK: - LayoutConstants
extension StatsViewController {
    private enum LayoutConstants {
        enum Stub {
            static let imageHeight: CGFloat = 80
            static let imageWidth: CGFloat = 80
            static let imageTopPadding: CGFloat = 220
            
            static let labelFont: UIFont = .systemFont(ofSize: 12, weight: .medium)
            static let textColor: UIColor = .ypBlack
            static let labelToImageSpacing: CGFloat = 8
        }
    }
}


extension StatsViewController {
    enum Strings {
        static let title = NSLocalizedString("statsTab.nav_title", comment: "")
        static let stubViewTitle = NSLocalizedString("statsTab.stub_title", comment: "")
    }
}
