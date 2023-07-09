//
//  UIView + Extension.swift
//  SmartThingsTestTask
//
//  Created by Артем Орлов on 08.07.2023.
//

import UIKit

extension UIView {
    func applyLinearGradient(colors: [UIColor], locations: [NSNumber]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

        layer.insertSublayer(gradientLayer, at: 0)
    }
}
