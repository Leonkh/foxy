//
//  MainScreenViewModel.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 30.12.2021.
//

import Foundation
import UIKit
import OpenCombine

protocol MainScreenViewModel {
    
    var viewStatePublisher: OpenCombine.Published<MainScreenViewState>.Publisher  { get }
    var notificationPublisher: OpenCombine.Published<PopupNotification>.Publisher  { get }
    var timeToRefreshPublisher: OpenCombine.Published<String>.Publisher { get }
    
    func start()
    func didTapFavoriteButton()
    func didTapTrashButton()
}

final class MainScreenViewModelImpl {
    
    @OpenCombine.Published private var viewState: MainScreenViewState = .loading
    @OpenCombine.Published private var notification: PopupNotification = .init(text: .empty, type: .information)
    @OpenCombine.Published private var timeToRefresh: String = ""
    
    private var cancellables: [AnyCancellable] = []
    private let model: MainScreenModel
//    private let router: MainScreenRouter
    private var currentMainPhoto: Photo?
    
    init(model: MainScreenModel) {
        self.model = model
//        self.router = router
        
        bindModel()
    }
    
    private func bindModel() {
        model.randomPhotoPublisher
            .receive(on: DispatchQueue.main.ocombine)
            .sink(receiveValue: { [weak self] photo in
            guard let self = self else {
                return
            }
            guard let photo = photo else {
                self.viewState = .loading
                return
            }
            
                if let image = photo.image {
                    self.currentMainPhoto = photo
                    let mainImageViewModel = ImageCell.Model(id: photo.id,
                                                             image: image,
                                                             isImageFavorite: photo.isFavorite)
                    let mainImageViewInfoModel = ImageInfoCell.Model(title: photo.title,
                                                                     owner: photo.owner)
                    let config = MainScreenViewConfig(mainImageViewModel: mainImageViewModel,
                                                      mainImageViewInfoModel: mainImageViewInfoModel)
                    self.viewState = .content(config: config)
                }
            }).store(in: &cancellables)
        
        model.networkStatusPublisher
            .receive(on: DispatchQueue.main.ocombine)
            .sink(receiveValue: { [weak self] status in
            guard let self = self else {
                return
            }
                
            switch status {
            case .enabled:
                self.notification = .init(text: "Снова в сети",
                                          type: .success)
            case .disabled:
                self.notification = .init(text: "Нет сети",
                                          type: .error)
            }
        }).store(in: &cancellables)
        
        model.timeToRefreshPublisher
            .receive(on: DispatchQueue.main.ocombine)
            .sink(receiveValue: { [weak self] time in
                guard let self = self else {
                    return
                }
                
                self.timeToRefresh = "Time to refresh " + time.description + "s"
            }).store(in: &cancellables)
    }
}

extension MainScreenViewModelImpl: MainScreenViewModel {
    
    // MARK: - MainScreenViewModel
    
    var viewStatePublisher: OpenCombine.Published<MainScreenViewState>.Publisher  { $viewState }
    
    var notificationPublisher: OpenCombine.Published<PopupNotification>.Publisher  { $notification }
    var timeToRefreshPublisher: OpenCombine.Published<String>.Publisher { $timeToRefresh }
    
    func start() {
        viewState = .loading
        model.start()
    }
    
    func didTapFavoriteButton() {
        guard let currentPhoto = currentMainPhoto else {
            return
        }
        
        model.didTapFavoriteButton(for: currentPhoto.id)
    }
    
    func didTapTrashButton() {
        model.didTapTrashButton()
    }
}
