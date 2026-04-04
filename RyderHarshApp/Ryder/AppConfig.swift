//
//  AppConfig.swift
//  RyderHarshApp
//
//  Created by Harsh on 04/04/26.
//

import Foundation

enum AppConfig {
    /// Fetch value from Info.plist
    private static func value(for key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            fatalError("❌ Missing \(key) in Info.plist")
        }
        return value
    }

    /// Google API Key
    static var googleAPIKey: String {
        return value(for: "GOOGLE_MAPS_API_KEY")
    }
}
