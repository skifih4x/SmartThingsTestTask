//
//  UILabel + Extension.swift
//  SmartThingsTestTask
//
//  Created by Артем Орлов on 09.07.2023.
//

import UIKit

extension UILabel {
    convenience init(fontSize: CGFloat = 14, textColor: UIColor = .white) {
        self.init()
        self.font = UIFont.systemFont(ofSize: fontSize)
        self.textColor = textColor
        self.numberOfLines = 0
    }
}
