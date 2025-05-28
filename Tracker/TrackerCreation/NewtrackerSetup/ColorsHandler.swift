//
//  ColorsHandler.swift
//  Tracker
//
//  Created by Vladimir on 28.05.2025.
//

import UIKit


final class ColorsHandler: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var choice: UIColor = .ypColorSelection1
    
    private let colors: [UIColor] = [
        .ypColorSelection1, .ypColorSelection2, .ypColorSelection3, .ypColorSelection4, .ypColorSelection5, .ypColorSelection6,
        .ypColorSelection7, .ypColorSelection8, .ypColorSelection9, .ypColorSelection10, .ypColorSelection11, .ypColorSelection12,
        .ypColorSelection13, .ypColorSelection14, .ypColorSelection15, .ypColorSelection16, .ypColorSelection17, .ypColorSelection18
    ]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorsCollectionViewCell.reuseID, for: indexPath) as? ColorsCollectionViewCell else {
            assertionFailure("EmojisHandler.collectionView: failed to dequeue cell")
            return UICollectionViewCell()
        }
        cell.color = colors[indexPath.item]
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
        choice = colors[indexPath.item]
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        LayoutConstants.lineSpacing
    }
}

extension ColorsHandler {
    enum LayoutConstants {
        static let itemSize = CGSize(width: 52, height: 52)
        static let interItemSpacing: CGFloat = 5
        static let insets = UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
        static let lineSpacing: CGFloat = 0
    }
}
