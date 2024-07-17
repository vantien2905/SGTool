//
//  AppDelegate.swift
//  Seed_Game
//
//  Created by Tien Dinh on 13/7/24.
//

import UIKit
//import netfox
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        NFX.sharedInstance().start()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        goToLaunch()
        return true
    }
    
    private func goToLaunch() {
        window = UIWindow(frame: UIScreen.main.bounds)
        let vc = HomeViewController.instantiateFromNib()
        vc.viewModel = HomeViewModel()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }

}

