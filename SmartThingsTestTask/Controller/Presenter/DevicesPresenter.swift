//
//  MainPresenter.swift
//  SmartThingsTestTask
//
//  Created by Артем Орлов on 07.07.2023.
//

import Foundation

protocol DevicesView: AnyObject {
    func showError(message: String)
    func showDevices(_ devices: [Device])
    func deleteDevice(at index: Int)
}

class DevicesPresenter {
    private let apiService: APIServiceProtocol
    weak var view: DevicesView?

    var devices: [Device] = []

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

    func fetchDevices() {

        apiService.fetchDevices { [weak self] result in
            DispatchQueue.main.async {

                switch result {
                case .success(let devices):
                    self?.devices = devices
                    self?.view?.showDevices(devices)
                case .failure(let error):
                    let errorMessage = self?.errorMessage(for: error)
                    self?.view?.showError(message: errorMessage ?? "не то")
                }
            }
        }
    }

    func deleteDevice(at index: Int) {
        guard index >= 0 && index < devices.count else { return }

        let device = devices[index]
        devices.remove(at: index)
        view?.deleteDevice(at: index)

        apiService.deleteDevice(id: device.id) { [weak self] result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self?.devices.insert(device, at: index)
                self?.view?.showDevices(self?.devices ?? [])

                let errorMessage = self?.errorMessage(for: error)
                self?.view?.showError(message: errorMessage ?? "не то")
            }
        }
    }

    private func errorMessage(for error: Error) -> String {
        switch error {
        case APIError.invalidURL:
            return "Неверный URL"
        case APIError.noDataReceived:
            return "Данные не получены"
        case APIError.invalidResponse:
            return "Неверный ответ сервера"
        case APIError.clientError(let statusCode):
            return "Ошибка клиента (статус код: \(statusCode))"
        case APIError.serverError(let statusCode):
            return "Ошибка сервера (статус код: \(statusCode))"
        default:
            return "Неизвестная ошибка"
        }
    }

}
