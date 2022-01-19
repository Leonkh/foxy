

import Foundation
import NeedleFoundation

// swiftlint:disable unused_declaration
private let needleDependenciesHash : String? = nil

// MARK: - Registration

public func registerProviderFactories() {
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->RootComponent") { component in
        return EmptyDependencyProvider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->RootComponent->FavoritesScreenComponent->MainScreenComponent") { component in
        return MainScreenDependency9e402a1f46102151b059Provider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->RootComponent->FavoritesScreenComponent") { component in
        return FavoritesScreenDependency27addd39e085479c7065Provider(component: component)
    }
    
}

// MARK: - Providers

private class MainScreenDependency9e402a1f46102151b059BaseProvider: MainScreenDependency {
    var coreDataManager: CoreDataManager {
        return rootComponent.coreDataManager
    }
    var networkManager: NetworkManager {
        return rootComponent.networkManager
    }
    var popupNotificationsManager: PopupNotificationsManager {
        return rootComponent.popupNotificationsManager
    }
    var favoritesScreenViewController: FavoritesScreenView {
        return favoritesScreenComponent.favoritesScreenViewController
    }
    private let favoritesScreenComponent: FavoritesScreenComponent
    private let rootComponent: RootComponent
    init(favoritesScreenComponent: FavoritesScreenComponent, rootComponent: RootComponent) {
        self.favoritesScreenComponent = favoritesScreenComponent
        self.rootComponent = rootComponent
    }
}
/// ^->RootComponent->FavoritesScreenComponent->MainScreenComponent
private class MainScreenDependency9e402a1f46102151b059Provider: MainScreenDependency9e402a1f46102151b059BaseProvider {
    init(component: NeedleFoundation.Scope) {
        super.init(favoritesScreenComponent: component.parent as! FavoritesScreenComponent, rootComponent: component.parent.parent as! RootComponent)
    }
}
private class FavoritesScreenDependency27addd39e085479c7065BaseProvider: FavoritesScreenDependency {
    var coreDataManager: CoreDataManager {
        return rootComponent.coreDataManager
    }
    private let rootComponent: RootComponent
    init(rootComponent: RootComponent) {
        self.rootComponent = rootComponent
    }
}
/// ^->RootComponent->FavoritesScreenComponent
private class FavoritesScreenDependency27addd39e085479c7065Provider: FavoritesScreenDependency27addd39e085479c7065BaseProvider {
    init(component: NeedleFoundation.Scope) {
        super.init(rootComponent: component.parent as! RootComponent)
    }
}
