//
//  AppDelegate.swift
//  RyderHarshApp
//
//  Created by Harsh on 04/04/26.
//

import GoogleMaps
import GooglePlaces
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let apiKey = AppConfig.googleAPIKey

           // Google Maps
           GMSServices.provideAPIKey(apiKey)

           // Google Places
           GMSPlacesClient.provideAPIKey(apiKey)

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
