//
//  TimeInterval + Extension.swift
//  SmartThingsTestTask
//
//  Created by Артем Орлов on 09.07.2023.
//

import Foundation

extension TimeInterval {
    func formattedTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: Date(timeIntervalSince1970: self))
    }
}
