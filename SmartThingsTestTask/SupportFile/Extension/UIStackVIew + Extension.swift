//
//  UIStackVIew + Extension.swift
//  SmartThingsTestTask
//
//  Created by Артем Орлов on 09.07.2023.
//

import UIKit

extension UIStackView {
    convenience init(axis: NSLayoutConstraint.Axis = .horizontal, spacing: CGFloat = 8) {
        self.init()
        self.axis = axis
        self.spacing = spacing
    }
}
