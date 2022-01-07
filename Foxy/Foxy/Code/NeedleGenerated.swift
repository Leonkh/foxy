

import Foundation
import NeedleFoundation

// swiftlint:disable unused_declaration
private let needleDependenciesHash : String? = nil

// MARK: - Registration

public func registerProviderFactories() {
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->RootComponent->MainScreenComponent") { component in
        return MainScreenDependency03fb5ba1afe26d2624c0Provider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->RootComponent") { component in
        return EmptyDependencyProvider(component: component)
    }
    
}

// MARK: - Providers

private class MainScreenDependency03fb5ba1afe26d2624c0BaseProvider: MainScreenDependency {
    var coreDataManager: CoreDataManager {
        return rootComponent.coreDataManager
    }
    var networkManager: NetworkManager {
        return rootComponent.networkManager
    }
    var popupNotificationsManager: PopupNotificationsManager {
        return rootComponent.popupNotificationsManager
    }
    private let rootComponent: RootComponent
    init(rootComponent: RootComponent) {
        self.rootComponent = rootComponent
    }
}
/// ^->RootComponent->MainScreenComponent
private class MainScreenDependency03fb5ba1afe26d2624c0Provider: MainScreenDependency03fb5ba1afe26d2624c0BaseProvider {
    init(component: NeedleFoundation.Scope) {
        super.init(rootComponent: component.parent as! RootComponent)
    }
}
