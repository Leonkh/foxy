//
//  RootComponent.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 31.12.2021.
//

import Foundation
import NeedleFoundation

final class RootComponent: BootstrapComponent {
    
    var coreDataManager: CoreDataManager {
        return shared { CoreDataManagerImpl() }
    }
    
    var networkManager: NetworkManager {
        return shared { NetworkManagerImpl() }
    }
    
    var popupNotificationsManager: PopupNotificationsManager {
        return shared { PopupNotificationsManagerImpl() }
    }
    
    var favoritesScreenDIComponent: FavoritesScreenComponent {
        return FavoritesScreenComponent(parent: self)
    }
    
}
