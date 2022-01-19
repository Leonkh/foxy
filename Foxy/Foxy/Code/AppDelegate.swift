//
//  AppDelegate.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 30.12.2021.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // MARK: - Properties
    
    private lazy var rootComponent = RootComponent()
    private lazy var mainScreenVC = rootComponent.favoritesScreenDIComponent.mainScreenDIComponent.mainScreenViewController
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Needle DI
        registerProviderFactories()
        
        // RootVC by code
        self.window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: mainScreenVC)
        window?.makeKeyAndVisible()
        return true
    }
    
}

