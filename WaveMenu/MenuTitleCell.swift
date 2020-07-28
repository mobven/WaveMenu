//
//  MenuTitleCell.swift
//  WaveBar
//
//  Created by Ali Hasanoğlu on 21.07.2020.
//  Copyright © 2020 Ali Hasanoğlu. All rights reserved.
//

import UIKit

class WMTitleCell: UICollectionViewCell {
    
    var titleLabelTextColor: UIColor = .black
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
        self.setupViews()
    }

    // MARK: Selecting cells
    override var isSelected: Bool {
        didSet {
            titleLabel.textColor = isSelected ? titleLabelSelectedTextColor : titleLabelTextColor
            _ = isSelected ? animateSelectedTitle() : setInitialSelectedTitle()
        }
    }
    
    func initViews(title: String){
        self.titleLabel.text = title
        titleLabel.textColor = isSelected ? titleLabelSelectedTextColor : titleLabelTextColor
        _ = isSelected ? animateSelectedTitle() : setInitialSelectedTitle()
    }
    
    func setInitialSelectedTitle(){
        titleLabel.removeFromSuperview()
        UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseIn, animations: { () -> () in
            self.setupViews()
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    func animateSelectedTitle(){
        addSubview(titleLabel)
        UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseIn, animations: { () -> () in
            self.addConstraintsWithFormat("V:|-3-[v0(20)]", views: self.titleLabel)
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
     func setupViews() {
        addSubview(titleLabel)
        addConstraintsWithFormat("H:[v0]", views: titleLabel)
        addConstraintsWithFormat("V:[v0(20)]-20-|", views: titleLabel)
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
    }
}




