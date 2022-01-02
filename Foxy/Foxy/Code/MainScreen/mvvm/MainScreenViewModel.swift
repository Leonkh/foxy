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
    
    func start()
    
    func didTapFavoriteButton()
}

final class MainScreenViewModelImpl {
    
    @OpenCombine.Published private var viewState: MainScreenViewState = .loading
    
    private var cancellable: OpenCombine.AnyCancellable?
    private let model: MainScreenModel
    private var currentMainPhoto: Photo?
    
    init(model: MainScreenModel) {
        self.model = model
        
        bindModel()
    }
    
    private func bindModel() {
        cancellable = model.randomPhotoPublisher.sink(receiveValue: { [weak self] photo in
            guard let self = self else {
                return
            }
            guard let photo = photo else {
                self.viewState = .loading
                return
            }
            
            let mainImageViewModel = ImageCell.Model(image: photo.image,
                                                     isImageFavorite: photo.isFavorite)
            let config = MainScreenViewConfig(mainImageViewModel: mainImageViewModel,
                                              timerLabelText: .empty,
                                              infoTexts: [photo.data.title])
            self.viewState = .content(config: config)
        })
    }
}

extension MainScreenViewModelImpl: MainScreenViewModel {
    
    // MARK: - MainScreenViewModel
    
    var viewStatePublisher: OpenCombine.Published<MainScreenViewState>.Publisher  { $viewState }
    
    func start() {
        viewState = .loading
        model.start()
    }
    
    func didTapFavoriteButton() {
        guard let currentPhoto = currentMainPhoto else {
            return
        }
        
        model.didTapFavoriteButton(for: currentPhoto.data.id)
    }
    
}
