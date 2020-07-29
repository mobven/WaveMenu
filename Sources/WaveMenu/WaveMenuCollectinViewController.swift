//
//  WaveMenuCollectinViewController.swift
//  WaveMenu
//
//  Created by Ali Hasanoğlu on 29.07.2020.
//  Copyright © 2020 Ali Hasanoğlu. All rights reserved.
//

import UIKit

    // MARK: CollectionView Delegate - DataSource - FlowLayout

    // swiftlint:disable:next line_length
class WaveMenuCollectinViewController: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // swiftlint:disable:previous line_length

    lazy var cellId = ""
    lazy var titleNames: [String] = []
    /// hold the collection view selected index for drawing bezire curve
    lazy var selectedCVIndex: Int = 0
    /// hold the collection view previous selected index for avoid reselection same cell
    lazy var previousSelectedIndex: Int = 0
    lazy var titleFont: UIFont = UIFont.systemFont(ofSize: 14)
    lazy var menuTitleTextColor: UIColor = .black
    lazy var menuTitleSelectedTextColor: UIColor = .white
    /// callback to return selectedCVIndex and previousSelectedIndex
    typealias CurveListener = (Int, Int) -> Void
    var curveListener: CurveListener?

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titleNames.count
    }
    // swiftlint:disable:next line_length
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // swiftlint:disable:previous line_length

        // swiftlint:disable:next force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! WMTitleCell
        // swiftlint:disable:previous force_cast
        cell.titleLabel.font = self.titleFont
        cell.titleLabelTextColor = menuTitleTextColor
        cell.titleLabelSelectedTextColor = menuTitleSelectedTextColor
        cell.initViews(title: titleNames[indexPath.item])
        return cell
    }

    // swiftlint:disable:next line_length
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / CGFloat(titleNames.count), height: collectionView.frame.height)
    // swiftlint:disable:previous line_length
    }

    // swiftlint:disable:next line_length
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    // swiftlint:disable:previous line_length
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        previousSelectedIndex = selectedCVIndex
        selectedCVIndex = indexPath.row

        /// avoiding reselection the same cell
        if previousSelectedIndex != selectedCVIndex, curveListener != nil {
            self.curveListener!(selectedCVIndex, previousSelectedIndex)
        }
    }
}
