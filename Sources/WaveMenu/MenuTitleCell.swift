//
//  MenuTitleCell.swift
//  WaveMenu
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

    var titleLeadingSpace: Double?
    var titleTrailingSpace: Double?
    var titleNumberOfLines: Int = 1
    var titleLineBreakMode: NSLineBreakMode = .byTruncatingTail
    var titleTextAlignment: NSTextAlignment = .natural

    // MARK: Components
    let titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        self.addTitleLabel()
        setLabelProperties()
    }

    // MARK: cell selection changed
    override var isSelected: Bool {
        didSet {
            titleLabel.textColor = isSelected ? titleLabelSelectedTextColor : titleLabelTextColor
            _ = isSelected ? setSelectedTitle() : setDeselectedTitle()
        }
    }

    /// set title text and initial selection for title
    func configureCell(with title: String) {
        self.titleLabel.text = title
        titleLabel.textColor = isSelected ? titleLabelSelectedTextColor: titleLabelTextColor
        _ = isSelected ? setSelectedTitle(): setDeselectedTitle()
    }

    /// Moves the deselected title to middle animatically
    private func setDeselectedTitle() {
        titleLabel.removeFromSuperview()
        UIView.animate(withDuration: 0.1, delay: 0.15, options: .curveEaseIn, animations: { [weak self] in
            self?.addTitleLabel()
            guard let label = self?.titleLabel else { return }
            self?.addConstraintsWithFormat("V:|-0-[v0]-(0)-|", views: label)
            self?.layoutIfNeeded()
        }, completion: nil)
    }

    /// Moves the selected title to top animatically
    private func setSelectedTitle() {
        titleLabel.removeFromSuperview()
        UIView.animate(withDuration: 0.1, delay: 0.5, options: .curveEaseIn, animations: { [weak self] in
            guard let label = self?.titleLabel else { return }
            self?.addTitleLabel()
            self?.addConstraintsWithFormat("V:|-0-[v0]-(20)-|", views: label)
            self?.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.titleLabel.layer.animateForBounce()
        })
    }

    /// This method adds titleLabel to cell
    private func addTitleLabel() {
        addSubview(titleLabel)
        addConstraintsWithFormat("H:[v0]", views: titleLabel)
        if let leadingSpace = titleLeadingSpace{
            addConstraint(NSLayoutConstraint(item: titleLabel,
                                             attribute: .leading,
                                             relatedBy: .equal,
                                             toItem: self,
                                             attribute: .leading,
                                             multiplier: 1,
                                             constant: leadingSpace))
        }
        if let trailingSpace = titleTrailingSpace{
            addConstraint(NSLayoutConstraint(item: titleLabel,
                                             attribute: .trailing,
                                             relatedBy: .equal,
                                             toItem: self,
                                             attribute: .trailing,
                                             multiplier: 1,
                                             constant: trailingSpace))
        }
        addConstraint(NSLayoutConstraint(item: titleLabel,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .centerX,
                                         multiplier: 1,
                                         constant: 0))
    }

    private func setLabelProperties() {
        titleLabel.numberOfLines = titleNumberOfLines
        titleLabel.lineBreakMode = titleLineBreakMode
        titleLabel.textAlignment = titleTextAlignment
        // auto resize label font size
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
    }

}
