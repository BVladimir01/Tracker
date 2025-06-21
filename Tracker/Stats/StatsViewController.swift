//
//  StatsViewController.swift
//  Tracker
//
//  Created by Vladimir on 01.05.2025.
//

import UIKit


final class StatsViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let statsService: StatsService
    private var statsObserver: NSObjectProtocol?
    
    private let stubView = UIView()
    private let trackersDoneCard = UIView()
    private let trackersDoneCounter = UILabel()
    private let trackersDoneSubtitle = UILabel()
    
    // MARK: - Initializers
    
    init(statsService: StatsService = .shared) {
        self.statsService = statsService
        super.init(nibName: nil, bundle: nil)
        addStatsObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.title
        view.backgroundColor = LayoutConstants.backgroundColor
        setUpStub()
        setUpTrackersDoneView()
        updateStubViewState()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addGradient(to: trackersDoneCard)
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
    
    private func setUpTrackersDoneView() {
        trackersDoneCard.layer.cornerRadius = LayoutConstants.Card.cornerRadius
        trackersDoneCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackersDoneCard)
        NSLayoutConstraint.activate([
            trackersDoneCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                  constant: LayoutConstants.firstCardSpacing),
            trackersDoneCard.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            trackersDoneCard.widthAnchor.constraint(equalToConstant: LayoutConstants.Card.width),
            trackersDoneCard.heightAnchor.constraint(equalToConstant: LayoutConstants.Card.height),
        ])
        
        trackersDoneCounter.text = String(statsService.totalTrackersDone)
        trackersDoneCounter.font = LayoutConstants.Card.counterFont
        trackersDoneCounter.textColor = LayoutConstants.Card.textColor
        trackersDoneCounter.translatesAutoresizingMaskIntoConstraints = false
        trackersDoneCard.addSubview(trackersDoneCounter)
        NSLayoutConstraint.activate([
            trackersDoneCounter.leadingAnchor.constraint(equalTo: trackersDoneCard.leadingAnchor,
                                                         constant: LayoutConstants.Card.horizontalPadding),
            trackersDoneCounter.topAnchor.constraint(equalTo: trackersDoneCard.topAnchor,
                                                     constant: LayoutConstants.Card.verticalPadding),
            trackersDoneCounter.trailingAnchor.constraint(lessThanOrEqualTo: trackersDoneCard.trailingAnchor,
                                                          constant: -LayoutConstants.Card.horizontalPadding),
        ])
        
        trackersDoneSubtitle.text = Strings.trackersDone
        trackersDoneSubtitle.font = LayoutConstants.Card.subtitleFont
        trackersDoneSubtitle.textColor = LayoutConstants.Card.textColor
        trackersDoneSubtitle.translatesAutoresizingMaskIntoConstraints = false
        trackersDoneCard.addSubview(trackersDoneSubtitle)
        NSLayoutConstraint.activate([
            trackersDoneSubtitle.topAnchor.constraint(equalTo: trackersDoneCounter.bottomAnchor,
                                                      constant: LayoutConstants.Card.labelsSpacing),
            trackersDoneSubtitle.leadingAnchor.constraint(equalTo: trackersDoneCounter.leadingAnchor),
            trackersDoneSubtitle.trailingAnchor.constraint(lessThanOrEqualTo: trackersDoneCard.trailingAnchor,
                                                           constant: -LayoutConstants.Card.horizontalPadding),
            trackersDoneSubtitle.bottomAnchor.constraint(lessThanOrEqualTo: trackersDoneCard.bottomAnchor,
                                                         constant: -LayoutConstants.Card.verticalPadding)
        ])
    }
    
    private func updateStubViewState() {
        setStubView(visible: statsService.totalTrackersDone == 0)
    }
    
    private func setStubView(visible: Bool) {
        stubView.isHidden = !visible
        if visible {
            view.bringSubviewToFront(stubView)
        } else {
            view.sendSubviewToBack(stubView)
        }
    }
    
    private func addGradient(to view: UIView) {
        let baseFrame = view.frame
        let biggerFrame = CGRect(origin: CGPoint(x: -1, y: -1),
                                     size: CGSize(width: baseFrame.width + 2, height: baseFrame.height + 2))
        
        let gradientLayer = CAGradientLayer()
        let colors = [
            LayoutConstants.Card.red,
            LayoutConstants.Card.green,
            LayoutConstants.Card.blue]
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.frame = biggerFrame
        gradientLayer.cornerRadius = view.layer.cornerRadius
        
        let blankLayer = CALayer()
        blankLayer.backgroundColor = LayoutConstants.Card.backgroundColor.cgColor
        blankLayer.frame = view.bounds
        blankLayer.cornerRadius = view.layer.cornerRadius
        
        view.layer.addSublayer(gradientLayer)
        view.layer.addSublayer(blankLayer)
        
        for subview in view.subviews {
            view.bringSubviewToFront(subview)
        }
    }
    
    private func addStatsObserver() {
        statsObserver = NotificationCenter.default.addObserver(forName: StatsService.statsDidChange,
                                                              object: statsService,
                                                              queue: .main) { [weak self] _ in
            self?.updateStats()
        }
    }
    
    private func updateStats() {
        trackersDoneCounter.text = String(statsService.totalTrackersDone)
        updateStubViewState()
    }
    
}


// MARK: - LayoutConstants
extension StatsViewController {
    private enum LayoutConstants {
        static let firstCardSpacing: CGFloat = 24
        static let backgroundColor: UIColor = .ypWhite
        enum Stub {
            static let imageHeight: CGFloat = 80
            static let imageWidth: CGFloat = 80
            static let imageTopPadding: CGFloat = 220
            
            static let labelFont: UIFont = .systemFont(ofSize: 12, weight: .medium)
            static let textColor: UIColor = .ypBlack
            static let labelToImageSpacing: CGFloat = 8
        }
        enum Card {
            static let backgroundColor: UIColor = .ypWhite
            static let width: CGFloat = 343
            static let height: CGFloat = 90
            static let red = UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1)
            static let green = UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1)
            static let blue = UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1)
            static let cornerRadius: CGFloat = 16
            static let verticalPadding: CGFloat = 12
            static let horizontalPadding: CGFloat = 12
            static let labelsSpacing: CGFloat = 7
            static let textColor: UIColor = .ypBlack
            static let counterFont: UIFont = .systemFont(ofSize: 34, weight: .bold)
            static let subtitleFont: UIFont = .systemFont(ofSize: 12, weight: .medium)
        }
        
    }
}


extension StatsViewController {
    enum Strings {
        static let title = NSLocalizedString("statsTab.nav_title", comment: "")
        static let stubViewTitle = NSLocalizedString("statsTab.stub_title", comment: "")
        static let trackersDone = NSLocalizedString("statsTab.trackersDone", comment: "")
    }
}
