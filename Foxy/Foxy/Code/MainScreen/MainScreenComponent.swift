//
//  MainScreenComponent.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 31.12.2021.
//

import Foundation
import NeedleFoundation

final class MainScreenComponent: Component<EmptyDependency> {
    var mainScreenModel: MainScreenModel {
        return MainScreenModelImpl()
    }
    
    var mainScreenViewModel: MainScreenViewModel {
        return MainScreenViewModelImpl(model: mainScreenModel)
    }
    
    var mainScreenViewController: MainScreenView {
        return MainScreenViewController(viewModel: mainScreenViewModel)
    }
    
}
