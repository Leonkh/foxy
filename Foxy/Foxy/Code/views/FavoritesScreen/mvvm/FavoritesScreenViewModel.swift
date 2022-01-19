//
//  FavoritesScreenViewModel.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 09.01.2022.
//

import Foundation
import OpenCombine

protocol FavoritesScreenViewModel {
    
    var viewStatePublisher: OpenCombine.Published<FavoritesScreenViewState>.Publisher  { get }
    
    func start()
}

final class FavoritesScreenViewModelImpl {
    
    @OpenCombine.Published private var viewState: FavoritesScreenViewState = .content(viewModel: FavoritesScreenViewConfig(imageCellModels: []))
    private let model: FavoritesScreenModel
    private var cancellables: [AnyCancellable] = []
    
    init(model: FavoritesScreenModel) {
        self.model = model
        
        bindModel()
    }
    
    private func bindModel() {
        model.favoritesPhotosPublisher
            .receive(on: DispatchQueue.main.ocombine)
            .sink(receiveValue: { [ weak self] favoritesPhotos in
                guard let self = self else {
                    return
                }
                
                let viewModels: [ImageCell.Model] = favoritesPhotos.compactMap { photo in
                    guard let image = photo?.image else {
                        return nil
                    }
                    
                    return ImageCell.Model(image: image,
                                           isImageFavorite: photo?.isFavorite ?? false)
                }
                self.viewState = .content(viewModel: FavoritesScreenViewConfig(imageCellModels: viewModels))
            }).store(in: &cancellables)
    }
    
}

extension FavoritesScreenViewModelImpl: FavoritesScreenViewModel {
    
    var viewStatePublisher: OpenCombine.Published<FavoritesScreenViewState>.Publisher  { $viewState }
    
    func start() {
        model.start()
    }
}
