//
//  DeviceModel.swift
//  SmartThingsTestTask
//
//  Created by Артем Орлов on 07.07.2023.
//

import Foundation

struct Device: Codable {
    let id: Int
    let name: String
    let icon: String
    let isOnline: Bool
    let type: Int
    let status: String
    let lastWorkTime: TimeInterval
}

struct DevicesResponse: Codable {
    let data: [Device]
}
