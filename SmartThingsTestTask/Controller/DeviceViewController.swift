//
//  DeviceViewController.swift
//  SmartThingsTestTask
//
//  Created by Артем Орлов on 07.07.2023.
//

import UIKit
import SnapKit

class DeviceViewController: UIViewController {

    // MARK: - Property

    private let presenter: DevicesPresenter
    private var headerHeightConstraint: NSLayoutConstraint!

    private var isLoading: Bool = false {
        didSet {
            refreshButton.isEnabled = !isLoading

            if isLoading {
                refreshButton.setTitle(nil, for: .normal)
                refreshButton.layer.cornerRadius = refreshButton.frame.height / 2
                loadingIndicator.startAnimating()
            } else {
                refreshButton.setTitle("Обновить", for: .normal)
                refreshButton.layer.cornerRadius = 8
                loadingIndicator.stopAnimating()
            }
        }
    }

    // MARK: - UIElement

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor(hex: "#19212C")
        tableView.showsHorizontalScrollIndicator = false
        return tableView
    }()

    private let headerView: UIView = {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(hex: "#19212C")
        return headerView
    }()

    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = """
        Умные
        вещи
        """
        titleLabel.font = UIFont.systemFont(ofSize: 24)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = UIColor(hex: "#885FF8")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.shadowColor = UIColor.black
        titleLabel.shadowOffset = CGSize(width: 2, height: 2)
        return titleLabel
    }()

    private lazy var refreshButton: UIButton = {
        let button = UIButton()
        button.setTitle("Обновить", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(refreshDevices), for: .touchUpInside)
        return button
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .black
        indicator.hidesWhenStopped = true
        return indicator
    }()
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 24)
        label.numberOfLines = 0
        return label
    }()

    private lazy var retryButton: UIButton = {
        let button = UIButton()
        button.setTitle("ПОВТОРИТЬ", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(retryFetchDevices), for: .touchUpInside)
        return button
    }()

    // MARK: - Init

    init(presenter: DevicesPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        self.presenter.view = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cicle view

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchDevices()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshButton.layer.cornerRadius = refreshButton.frame.height / 2
        retryButton.layer.cornerRadius = retryButton.frame.height / 2
    }

    // MARK: - Private methods

    private func fetchDevices() {
        errorLabel.isHidden = true
        retryButton.isHidden = true
        tableView.isHidden = false

        presenter.fetchDevices()
    }

    @objc private func refreshDevices() {
        isLoading = true

        refreshButton.snp.updateConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.refreshButton.layer.cornerRadius = 25
        }

        loadingIndicator.startAnimating()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.isLoading = false

            self?.refreshButton.snp.updateConstraints { make in
                make.width.equalTo(143)
                make.height.equalTo(51)
            }
            UIView.animate(withDuration: 0.3) {
                self?.view.layoutIfNeeded()
                self?.presenter.fetchDevices()
                self?.refreshButton.layer.cornerRadius = (self?.refreshButton.frame.height ?? CGFloat()) / 2
            }

            self?.loadingIndicator.stopAnimating()
        }
    }
}

// MARK: - DevicesView

extension DeviceViewController: DevicesView {
    func showError(message: String) {
        errorLabel.text = "Что-то пошло не так \(message)"
        errorLabel.isHidden = false
        retryButton.isHidden = false
        tableView.isHidden = true
        refreshButton.isHidden = true
    }

    func showDevices(_ devices: [Device]) {
        tableView.reloadData()
    }

    func deleteDevice(at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    @objc private func retryFetchDevices() {
        fetchDevices()
    }
}

// MARK: - UITableViewDataSource

extension DeviceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.devices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DeviceCell.identifier, for: indexPath) as? DeviceCell else {
            return UITableViewCell()
        }

        let device = presenter.devices[indexPath.row]
        cell.configure(with: device)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension DeviceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.cornerRadius = 20
        cell.clipsToBounds = true

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        300
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "УДАЛИТЬ") { [weak self] (_, _, completion) in
            self?.showAlertForDeletion(at: indexPath)
            completion(true)
        }

        deleteAction.backgroundColor = UIColor(hex: "#FF6969")

        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeActions.performsFirstActionWithFullSwipe = false

        return swipeActions
    }
}

// MARK: - AlertController

extension DeviceViewController {
    private func showAlertForDeletion(at indexPath: IndexPath) {
        let device = presenter.devices[indexPath.row]

        let alertController = RoundedAlertController(title: nil, message: "Вы хотите удалить \(device.name)?", preferredStyle: .alert)
        alertController.view.tintColor = .black
        alertController.view.backgroundColor = .white

        alertController.addAction(UIAlertAction(title: "ОТМЕНА", style: .default, handler: { [weak self] _ in
            self?.restoreCellProperties(at: indexPath)
        }))

        alertController.addAction(UIAlertAction(title: "УДАЛИТЬ", style: .destructive, handler: { [weak self] _ in
            self?.presenter.deleteDevice(at: indexPath.row)
        }))

        present(alertController, animated: true, completion: nil)
    }

    private func restoreCellProperties(at indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        cell.layer.cornerRadius = 20
        cell.clipsToBounds = true
    }
}

// MARK: - ScrollView

extension DeviceViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        scrollView.showsVerticalScrollIndicator = false
        if offsetY < 0 {
            headerHeightConstraint.constant = 80 - offsetY
        } else {
            headerHeightConstraint.constant = 80
        }
    }
}

// MARK: - SetupUI

extension DeviceViewController {
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#19212C")

        tableView.register(DeviceCell.self, forCellReuseIdentifier: DeviceCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
        view.addSubview(errorLabel)
        view.addSubview(retryButton)
        headerView.addSubview(titleLabel)
        view.addSubview(refreshButton)
        tableView.tableHeaderView = headerView
        tableView.tableHeaderView?.frame.size.height = 80

        headerHeightConstraint = headerView.heightAnchor.constraint(equalToConstant: 80)
        headerHeightConstraint.isActive = true

        refreshButton.addSubview(loadingIndicator)

        errorLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        retryButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(errorLabel.snp.bottom).offset(16)
            make.width.equalTo(143)
            make.height.equalTo(51)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(headerView).offset(8)
            make.bottom.equalTo(headerView).offset(-8)
        }


        refreshButton.snp.makeConstraints { make in
            make.width.equalTo(143)
            make.height.equalTo(51)
            make.bottom.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
        }

        loadingIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
}
