//
//  EmojisHandler.swift
//  Tracker
//
//  Created by Vladimir on 28.05.2025.
//

import UIKit


// MARK: - EmojisHandlerDelegate
protocol EmojisHandlerDelegate: AnyObject {
    func emojisHandler(_ handler: EmojisHandler, didSelect emoji: String)
}


// MARK: - EmojisHandler
final class EmojisHandler: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Internal Properties
    
    weak var delegate: EmojisHandlerDelegate?
    
    // MARK: - Private Properties
    
    private let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
    
    // MARK: - Internal Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojisCollectionViewCell.reuseID, for: indexPath) as? EmojisCollectionViewCell else {
            assertionFailure("EmojisHandler.collectionView: failed to dequeue cell")
            return UICollectionViewCell()
        }
        cell.emoji = emojis[indexPath.item]
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        LayoutConstants.itemSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        LayoutConstants.interItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        LayoutConstants.insets
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.emojisHandler(self, didSelect: emojis[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        LayoutConstants.lineSpacing
    }
}


// MARK: - LayoutConstants
extension EmojisHandler {
    enum LayoutConstants {
        static let itemSize = CGSize(width: 52, height: 52)
        static let interItemSpacing: CGFloat = 5
        static let insets = UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
        static let lineSpacing: CGFloat = 0
    }
}
