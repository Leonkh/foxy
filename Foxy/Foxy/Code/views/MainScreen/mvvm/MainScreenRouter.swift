//
//  MainScreenRouter.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 09.01.2022.
//

import Foundation

protocol MainScreenRouter {
    
    func openFavorites()
    
}

final class MainScreenRouterImpl {
    
    private weak var view: MainScreenView?
    private let favoritesScreen: FavoritesScreenView
    
    init(view: MainScreenView,
         favoritesScreen: FavoritesScreenView) {
        self.view = view
        self.favoritesScreen = favoritesScreen
    }
    
}

extension MainScreenRouterImpl: MainScreenRouter {
    
    func openFavorites() {
        guard let navigationController = view?.navigationController else {
            return
        }
        
        navigationController.pushViewController(favoritesScreen, animated: true)
    }
    
}
