//
//  AppBuilder.swift
//  SmartThingsTestTask
//
//  Created by Артем Орлов on 09.07.2023.
//

import UIKit

protocol AppBuilderProtocol {
    func buildMainViewController() -> DeviceViewController
}

class AppBuilder: AppBuilderProtocol {
    func buildMainViewController() -> DeviceViewController {
        let apiService = APIService()
        let presenter = DevicesPresenter(apiService: apiService)
        let viewController = DeviceViewController(presenter: presenter)
        presenter.view = viewController
        return viewController
    }
}
