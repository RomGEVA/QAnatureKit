//
//  AppDelegate.swift
//  QAnatureKit
//
//  Created by Роман Главацкий on 20.05.2025.
//

import UIKit
import OneSignalFramework
import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var restrictRotation: UIInterfaceOrientationMask = .all
    private let oneSignalIDCheker = OneSignalIDChecker()

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return restrictRotation
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        OneSignal.initialize("7372db9c-fa89-4645-b21f-aee9b057a206", withLaunchOptions: nil)
        oneSignalIDCheker.startCheckingOneSignalID()
        initViewControllers()
        return true
    }
    
    private func initViewControllers() {
        let controller: UIViewController
        if let lastUrl = SaveService.lastUrl {
            controller = WebviewVC(url: lastUrl)
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = controller
            window?.makeKeyAndVisible()
            print("saved")
        }else{
            controller = LoadingSplash()
            //let NavigationController = UINavigationController(rootViewController: controller)
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = UIHostingController(rootView: MainTabView())
           // window?.rootViewController = NavigationController
            window?.makeKeyAndVisible()
            print("not saved")
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

