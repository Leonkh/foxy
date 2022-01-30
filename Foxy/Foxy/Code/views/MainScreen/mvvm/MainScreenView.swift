//
//  MainScreenView.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 30.12.2021.
//

import Foundation
import UIKit
import SnapKit
import OpenCombine

enum MainScreenViewState: Hashable {
    case content(config: MainScreenViewConfig)
    case loading
}

struct MainScreenViewConfig: Hashable {
    let mainImageViewModel: ImageCell.Model
    let mainImageViewInfoModel: ImageInfoCell.Model
}

// MARK: - Protocol
protocol MainScreenView: UIViewController {
    
}

final class MainScreenViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let backgroundColor = UIColor.white
        static let refreshControlTintColor = UIColor.black
        static let barTintColor = UIColor.white
        static let titleTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black
        ]
        static let favoritesTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black
        ]
    }
    
    
    // MARK: - Properties
    
    private let viewModel: MainScreenViewModel
    private let popupNotificationsManager: PopupNotificationsManager
    private var cancellables = [AnyCancellable]()
    private var config: MainScreenViewConfig?
    private let favoritesView: FavoritesScreenView
    
    
    // MARK: - Views
    
    private lazy var timerLabel: UILabel = .create { label in
        label.textAlignment = .center
        label.textColor = .black
        label.backgroundColor = .white
        label.text = "test text"
    }
    
    private lazy var tableView: UITableView = .create { tableView in
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = Constants.refreshControlTintColor
        refreshControl.addTarget(self,
                                 action: #selector(refreshTable),
                                 for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.backgroundColor = Constants.backgroundColor
        tableView.register(ImageCell.self, forCellReuseIdentifier: ImageCell.identifier)
        tableView.register(ImageInfoCell.self, forCellReuseIdentifier: ImageInfoCell.identifier)
        tableView.separatorStyle = .none
        tableView.dataSource = self
    }
    
    private lazy var trashButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .trash,
                                     target: self,
                                     action: #selector(didTapTrashButton))
        return button
    }()
    
    private lazy var favoritesButton: UIBarButtonItem = {
        let favoritesButton = UIButton(type: .system)
        let attrText = NSMutableAttributedString(string: "Избранное",
                                                 attributes: Constants.favoritesTextAttributes)
        if let forwardImage = UIImage(named: "forwardIcon") {
            attrText.appendImage(forwardImage, with: 17)
        }
        favoritesButton.setAttributedTitle(attrText, for: .normal)
        favoritesButton.addTarget(self,
                                  action: #selector(didTapNavBarFavoriteButton),
                                  for: .touchUpInside)
        let button = UIBarButtonItem(customView: favoritesButton)
        return button
    }()
    
    
    // MARK: - Init
    
    init(viewModel: MainScreenViewModel,
         popupNotificationsManager: PopupNotificationsManager,
         favoritesView: FavoritesScreenView) {
        self.viewModel = viewModel
        self.popupNotificationsManager = popupNotificationsManager
        self.favoritesView = favoritesView
        super.init(nibName: nil, bundle: nil)
        
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupLayout()
        setupNavBar()
        viewModel.start()
    }
    
    // MARK: - Private methods
    
    private func setupLayout() {
        view.addSubviews([timerLabel, tableView])
        
        timerLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(timerLabel.snp.bottom).offset(12)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupNavBar() {
        navigationItem.leftBarButtonItem = trashButton
        navigationItem.rightBarButtonItem = favoritesButton
        navigationController?.navigationBar.barTintColor = Constants.barTintColor
        title = "Главный экран"
        navigationController?.navigationBar.titleTextAttributes = Constants.titleTextAttributes
    }
    
    private func bindViewModel() {
        viewModel.viewStatePublisher.sink { [weak self] state in
            guard let self = self else {
                return
            }
            
            self.apply(state: state)
        }.store(in: &cancellables)
        
        viewModel.notificationPublisher.sink { [weak self] notification in
            guard let self = self else {
                return
            }
            
            self.popupNotificationsManager.displayTopPopUp(notification: notification)
        }.store(in: &cancellables)
        
        viewModel.timeToRefreshPublisher.sink(receiveValue: { [weak self] time in
            guard let self = self else {
                return
            }
            
            self.timerLabel.text = time
        }).store(in: &cancellables)
    }
    
    private func apply(state: MainScreenViewState) {
        setLoadingState(isLoading: state == .loading)
        switch state {
        case .content(let config):
            self.config = config
        case .loading:
            self.config = nil
            break
        }
        tableView.reloadData()
    }
    
    private func setLoadingState(isLoading: Bool) {
        if isLoading {
            tableView.refreshControl?.beginRefreshing()
        } else {
            tableView.refreshControl?.endRefreshing()
        }
    }
    
    @objc private func refreshTable() {
        viewModel.start()
    }
    
    @objc private func didTapTrashButton() {
        viewModel.didTapTrashButton()
    }
    
    @objc private func didTapNavBarFavoriteButton() {
        print("didTapNavBarFavoriteButton")
        navigationController?.pushViewController(favoritesView, animated: true)
    }
    
}

extension MainScreenViewController: MainScreenView {
    // MARK: - MainScreenView
}

extension MainScreenViewController: UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard config != nil else {
            return .zero
        }
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let config = config else {
            return UITableViewCell()
        }
        
        if indexPath.row == .zero {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageCell.identifier) as? ImageCell else {
                return UITableViewCell()
            }
            
            cell.setup(model: config.mainImageViewModel,
                       delegate: self)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageInfoCell.identifier) as? ImageInfoCell else {
                return UITableViewCell()
            }
            
            cell.setup(model: config.mainImageViewInfoModel)
            return cell
        }
    }
    
}

extension MainScreenViewController: ImageCellDelegate {
    
    // MARK: - ImageCellDelegate
    
    func didTapFavoriteButton(forImage id: String) {
        viewModel.didTapFavoriteButton()
    }
    
}
