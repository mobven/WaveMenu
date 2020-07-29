//
//  UIView+Extension.swift
//  WaveBar
//
//  Created by Ali Hasanoğlu on 21.07.2020.
//  Copyright © 2020 Ali Hasanoğlu. All rights reserved.
//

import UIKit

extension UIView {
    /// This method add constraints to views via visual format language (Auto Layout).
    ///
    ///  Example: "V:|-3-[v0(20)]"
    ///
    ///     V represent vertical,
    ///     | represent superview,
    ///     v0 represent view item
    ///
    ///     v0 has top constraint to superview 3 pt and v0 has 20 pt height constraint.
    ///
    /// Check visual format language for detail description.
    ///
    /// - parameter format: visual format.
    /// - parameter views: uiViews which will take constraints.

    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format,
                                                      options: NSLayoutConstraint.FormatOptions(),
                                                      metrics: nil,
                                                      views: viewsDictionary))
    }
}
