//
//  MenuTitleCell.swift
//  WaveBar
//
//  Created by Ali Hasanoğlu on 21.07.2020.
//  Copyright © 2020 Ali Hasanoğlu. All rights reserved.
//

import UIKit

class WMTitleCell: UICollectionViewCell {

    /// titleLabel deselected text color
    var titleLabelTextColor: UIColor = .black
    /// titleLabel selected text color
    var titleLabelSelectedTextColor: UIColor = .white

    // MARK: Components
    let titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        self.initializeViews()
    }

    // MARK: cell selection changed
    override var isSelected: Bool {
        didSet {
            titleLabel.textColor = isSelected ? titleLabelSelectedTextColor : titleLabelTextColor
            _ = isSelected ? setSelectedTitle() : setDeselectedTitle()
        }
    }

    /// set title text and initial selection for title
    func initViews(title: String) {
        self.titleLabel.text = title
        titleLabel.textColor = isSelected ? titleLabelSelectedTextColor : titleLabelTextColor
        _ = isSelected ? setSelectedTitle() : setDeselectedTitle()
    }

    /// Moves the deselected title to middle animatically
    private func setDeselectedTitle() {
        titleLabel.removeFromSuperview()
        UIView.animate(withDuration: 0.1, delay: 0.15, options: .curveEaseIn, animations: { () -> Void in
            self.initializeViews()
            self.layoutIfNeeded()
        }, completion: nil)
    }

    /// Moves the selected title to top animatically
    private func setSelectedTitle() {
        addSubview(titleLabel)
        UIView.animate(withDuration: 0.1, delay: 0.5, options: .curveEaseIn, animations: { () -> Void in
            self.addConstraintsWithFormat("V:|-3-[v0]", views: self.titleLabel)
            self.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.titleLabel.layer.animateForBounce()
        })
    }

    /// This method adds titleLabel to cell
     private func initializeViews() {
        addSubview(titleLabel)
        addConstraintsWithFormat("H:[v0]", views: titleLabel)
        addConstraintsWithFormat("V:[v0]-20-|", views: titleLabel)
        addConstraint(NSLayoutConstraint(item: titleLabel,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .centerX,
                                         multiplier: 1,
                                         constant: 0))
    }
}
