//
//  CALayer+Extension.swift
//  WaveMenu
//
//  Created by Ali Hasanoğlu on 29.09.2020.
//  Copyright © 2020 Ali Hasanoğlu. All rights reserved.
//

import UIKit

extension CALayer {
    ///Bounce animation of layer in y position
    func animateForBounce() {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.y"
        animation.values = [0, -3, 0]
        animation.keyTimes = [0, 0.5, 1]
        animation.duration = 0.6
        animation.isAdditive = true
        self.add(animation, forKey: "shake")
    }
}
