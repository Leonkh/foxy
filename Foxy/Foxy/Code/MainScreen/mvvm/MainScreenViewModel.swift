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
    
    func start()
    func didTapFavoriteButton()
    func didTapTrashButton()
}

final class MainScreenViewModelImpl {
    
    @OpenCombine.Published private var viewState: MainScreenViewState = .loading
    @OpenCombine.Published private var notification: PopupNotification = .init(text: .empty, type: .information)
    
    private var cancellables: [AnyCancellable] = []
    private let model: MainScreenModel
    private var currentMainPhoto: Photo?
    
    init(model: MainScreenModel) {
        self.model = model
        
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
                let mainImageViewModel = ImageCell.Model(image: image,
                                                         isImageFavorite: photo.isFavorite)
                let config = MainScreenViewConfig(mainImageViewModel: mainImageViewModel,
                                                  timerLabelText: .empty,
                                                  infoTexts: [photo.title])
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
    }
}

extension MainScreenViewModelImpl: MainScreenViewModel {
    
    // MARK: - MainScreenViewModel
    
    var viewStatePublisher: OpenCombine.Published<MainScreenViewState>.Publisher  { $viewState }
    
    var notificationPublisher: OpenCombine.Published<PopupNotification>.Publisher  { $notification }
    
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
