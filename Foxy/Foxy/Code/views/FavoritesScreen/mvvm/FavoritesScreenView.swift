//
//  FavoritesScreenView.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 09.01.2022.
//

import Foundation
import UIKit
import SnapKit
import OpenCombine

enum FavoritesScreenViewState {
    /// TODO: case empty
    case content(viewModel: FavoritesScreenViewConfig)
}

struct FavoritesScreenViewConfig {
    let imageCellModels: [ImageCell.Model]
}

protocol FavoritesScreenView: UIViewController {
    
}

final class FavoritesScreenViewImpl: UIViewController, FavoritesScreenView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let backgroundColor = UIColor.white
        static let titleTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black
        ]
    }
    
    
    // MARK: - Properties
    
    private let viewModel: FavoritesScreenViewModel
    private var config: FavoritesScreenViewConfig = .init(imageCellModels: [])
    private var cancellable: AnyCancellable?
    private lazy var tableView: UITableView = .create { tableView in
        tableView.backgroundColor = Constants.backgroundColor
        tableView.register(ImageCell.self, forCellReuseIdentifier: ImageCell.identifier)
        tableView.separatorStyle = .none
        tableView.dataSource = self
    }
    
    
    // MARK: - Init
    
    init(viewModel: FavoritesScreenViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.start()
        tableView.setContentOffset(.zero, animated: false)
    }
    
    
    // MARK: - Private methdos
    
    private func bindViewModel() {
        cancellable = viewModel.viewStatePublisher.sink(receiveValue: { [weak self] state in
            guard let self = self else {
                return
            }
            
            self.apply(state: state)
        })
    }
    
    private func setupLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.directionalEdges.equalToSuperview()
        }
    }
    
    private func setupNavBar() {
        title = "Избранное"
        navigationController?.navigationBar.titleTextAttributes = Constants.titleTextAttributes
    }
    
    private func apply(state: FavoritesScreenViewState) {
        switch state {
        case .content(let viewModel):
            config = viewModel
        }
        tableView.reloadData()
    }
    
}

extension FavoritesScreenViewImpl: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return config.imageCellModels.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageCell.identifier) as? ImageCell else {
            return UITableViewCell()
        }
        
        guard let imageCellViewModel = config.imageCellModels[safe: indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.setup(model: imageCellViewModel,
                   delegate: self)
        return cell
    }
    
}

extension FavoritesScreenViewImpl: ImageCellDelegate {
    
    func didTapFavoriteButton(forImage id: String) {
        viewModel.didTapFavoriteButton(for: id)
    }
    
}
