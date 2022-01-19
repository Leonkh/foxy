//
//  FavoritesScreenComponent.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 09.01.2022.
//

import Foundation
import NeedleFoundation

protocol FavoritesScreenDependency: Dependency {
    var coreDataManager: CoreDataManager { get }
}

final class FavoritesScreenComponent: Component<FavoritesScreenDependency> {
    
    var favoritesScreenModel: FavoritesScreenModel {
        return FavoritesScreenModelImpl(coreDataManager: dependency.coreDataManager)
    }
    
    var favoritesScreenViewModel: FavoritesScreenViewModel {
        return FavoritesScreenViewModelImpl(model: favoritesScreenModel)
    }
    
    var favoritesScreenViewController: FavoritesScreenView {
        return FavoritesScreenViewImpl(viewModel: favoritesScreenViewModel)
    }
    
    var mainScreenDIComponent: MainScreenComponent {
        return MainScreenComponent(parent: self)
    }
    
}
