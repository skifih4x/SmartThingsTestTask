//
//  MainCell.swift
//  SmartThingsTestTask
//
//  Created by Артем Орлов on 07.07.2023.
//

import SnapKit
import UIKit
import WebKit

class DeviceCell: UITableViewCell {
    static let identifier = "DeviceCell"

    private let gradientLayer = CAGradientLayer()

    private let statusView = UIView()
    private let statusLabel = UILabel(fontSize: 18, textColor: .white)

    private let nameDeviceLabel = UILabel(fontSize: 40, textColor: .black)

    private var deviceWebView = WKWebView()

    private let typeStackView = UIStackView(axis: .horizontal, spacing: 8)
    private let typeImage = UIImageView()
    private let typeLabel = UILabel(fontSize: 18, textColor: .white)

    private let timeStackView = UIStackView(axis: .horizontal, spacing: 8)
    private let timeImage = UIImageView()
    private let timeLabel = UILabel(fontSize: 18, textColor: .white)

    override open var frame: CGRect {
        get {
            return super.frame
        }
        set {
            var frame =  newValue
            frame.size.height -= 40
            super.frame = frame
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = contentView.bounds
        deviceWebView.layer.cornerRadius = deviceWebView.frame.height / 2
        deviceWebView.clipsToBounds = true
    }

    func configure(with device: Device) {
        statusView.backgroundColor = device.isOnline ? .green : .red
        statusLabel.text = device.status
        nameDeviceLabel.text = device.name
        typeLabel.text = String(device.type)
        timeLabel.text = device.lastWorkTime.formattedTimeString()

        let htmlString = """
        <html>
        <head>
        <style>
        body {
            margin: 0;
            padding: 0;
            overflow: hidden;
        }
        img {
            width: 40%;
            height: 40%;
            object-fit: contain;
        }
        </style>
        </head>
        <body>
        <img src="https://api.fasthome.io\(device.icon)" />
        </body>
        </html>
        """
        deviceWebView.loadHTMLString(htmlString, baseURL: nil)

        timeImage.image = UIImage(systemName: "clock.fill")
        typeImage.image = UIImage(systemName: "clock.fill")
    }
}

// MARK: - SetupUI

private extension DeviceCell {
    func setupUI() {
        contentView.addSubview(statusView)
        contentView.addSubview(statusLabel)
        contentView.addSubview(nameDeviceLabel)
        contentView.addSubview(deviceWebView)
        contentView.addSubview(typeStackView)
        typeStackView.addArrangedSubview(typeImage)
        typeStackView.addArrangedSubview(typeLabel)
        contentView.addSubview(timeStackView)
        timeStackView.addArrangedSubview(timeImage)
        timeStackView.addArrangedSubview(timeLabel)

        statusView.layer.cornerRadius = 6

        typeStackView.backgroundColor = UIColor(hex: "#232198")
        typeStackView.layer.cornerRadius = 10
        typeStackView.alignment = .fill
        typeStackView.distribution = .fillEqually

        deviceWebView.scrollView.isScrollEnabled = false

        timeImage.contentMode = .scaleAspectFit
        timeImage.tintColor = UIColor(hex: "#A2A1FF")

        typeImage.tintColor = UIColor(hex: "#A2A1FF")
        typeImage.contentMode = .scaleAspectFit

        setupGradientLayer()

        statusView.snp.makeConstraints { make in
            make.width.height.equalTo(12)
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
        }

        statusLabel.snp.makeConstraints { make in
            make.leading.equalTo(statusView.snp.trailing).offset(5)
            make.centerY.equalTo(statusView)
        }

        nameDeviceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(deviceWebView.snp.leading).offset(-8)
            make.top.equalTo(statusLabel.snp.bottom).offset(8)
        }

        deviceWebView.snp.makeConstraints { make in
            make.width.height.equalTo(98)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(nameDeviceLabel)
        }

        typeStackView.snp.makeConstraints { make in
            make.leading.equalTo(nameDeviceLabel)
            make.bottom.equalToSuperview().offset(-16)
        }

        timeStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    func setupGradientLayer() {
        gradientLayer.frame = contentView.bounds
        gradientLayer.colors = [UIColor(hex: "#AB69FF").cgColor, UIColor(hex: "#494BEB").cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        contentView.layer.insertSublayer(gradientLayer, at: 0)
    }
}
