//
//  MainScreenComponent.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 31.12.2021.
//

import Foundation
import NeedleFoundation

protocol MainScreenDependency: Dependency {
    var coreDataManager: CoreDataManager { get }
    var networkManager: NetworkManager { get }
    var popupNotificationsManager: PopupNotificationsManager { get }
    var favoritesScreenViewController: FavoritesScreenView { get }
}

final class MainScreenComponent: Component<MainScreenDependency> {
    
    var mainScreenModel: MainScreenModel {
        return MainScreenModelImpl(coreDataManager: dependency.coreDataManager,
                                   networkManager: dependency.networkManager)
    }
    /// ждём решения https://github.com/uber/needle/issues/396
//    var mainScreenRouter: MainScreenRouter {
//        return MainScreenRouterImpl(view: mainScreenViewController,
//                                    favoritesScreen: dependency.favoritesScreenViewController)
//    }
    
    var mainScreenViewModel: MainScreenViewModel {
        return MainScreenViewModelImpl(model: mainScreenModel)
    }
    
    var mainScreenViewController: MainScreenView {
        return MainScreenViewController(viewModel: mainScreenViewModel,
                                        popupNotificationsManager: dependency.popupNotificationsManager,
                                        favoritesView: dependency.favoritesScreenViewController)
    }
    
}
