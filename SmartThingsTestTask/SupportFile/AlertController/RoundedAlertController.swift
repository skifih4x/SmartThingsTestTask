//
//  RoundedAlertController.swift
//  SmartThingsTestTask
//
//  Created by Артем Орлов on 09.07.2023.
//

import UIKit

class RoundedAlertController: UIAlertController {
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.layer.cornerRadius = 20
    }
}
