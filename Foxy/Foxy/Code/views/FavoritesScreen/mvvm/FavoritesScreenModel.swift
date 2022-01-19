//
//  FavoritesScreenModel.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 09.01.2022.
//

import Foundation
import OpenCombine

protocol FavoritesScreenModel {
    var favoritesPhotosPublisher: OpenCombine.Published<[Photo?]>.Publisher  { get }
    
    func start()
    func didTapFavoriteButton(for photoId: String)
}

final class FavoritesScreenModelImpl {
    
    @OpenCombine.Published private var favoritesPhotos = [Photo?]()
    private let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
}

extension FavoritesScreenModelImpl: FavoritesScreenModel {
    
    var favoritesPhotosPublisher: OpenCombine.Published<[Photo?]>.Publisher  {
        $favoritesPhotos
    }
    
    func start() {
        coreDataManager.loadPhotos { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let photos):
                self.favoritesPhotos = photos.filter { $0.isFavorite }
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    func didTapFavoriteButton(for photoId: String) {
        coreDataManager.togglePhotoIsFavorite(photoId: photoId) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success:
                self.start()
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
}
