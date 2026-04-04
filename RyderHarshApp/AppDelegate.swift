//
//  AppDelegate.swift
//  RyderHarshApp
//
//  Created by Harsh on 04/04/26.
//

import UIKit
import GoogleMaps
import GooglePlaces

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GMSPlacesClient.provideAPIKey("")
        GMSServices.provideAPIKey("")
        
        // CRITICAL: If app is killed and system wakes it up for location
        if let _ = launchOptions?[.location] {
            print("🚀 [AppDelegate] App launched by Location System (Background/Killed state)")
            RiderLocationManager.shared.startTracking()
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
