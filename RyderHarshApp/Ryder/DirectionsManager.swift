//
//  DirectionsManager.swift
//  RyderHarshApp
//
//  Created by Harsh on 04/04/26.
//

import CoreLocation
import Foundation
import GoogleMaps

final class DirectionsManager {
    static let shared = DirectionsManager()
    private init() {}

    /// Fetch route using Google Routes API
    func fetchRoute(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        completion: @escaping (GMSPath?) -> Void
    ) {
        let apiKey = AppConfig.googleAPIKey
        let urlString = "https://routes.googleapis.com/directions/v2:computeRoutes"

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            DispatchQueue.main.async { completion(nil) }
            return
        }

        // MARK: - Request Body (Cleaned)

        let body: [String: Any] = [
            "origin": [
                "location": [
                    "latLng": [
                        "latitude": origin.latitude,
                        "longitude": origin.longitude,
                    ],
                ],
            ],
            "destination": [
                "location": [
                    "latLng": [
                        "latitude": destination.latitude,
                        "longitude": destination.longitude,
                    ],
                ],
            ],
            "travelMode": "DRIVE",
            "routingPreference": "TRAFFIC_AWARE",
            "computeAlternativeRoutes": false,
            "routeModifiers": [
                "avoidTolls": false,
                "avoidHighways": false,
                "avoidFerries": false,
            ],
            "languageCode": "en-US",
            "units": "METRIC",
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 10

        // MARK: - Headers

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue(
            "routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline",
            forHTTPHeaderField: "X-Goog-FieldMask"
        )

        // MARK: - Encode Body

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("❌ Encoding failed: \(error)")
            DispatchQueue.main.async { completion(nil) }
            return
        }

        print("🌐 Requesting route...")

        // MARK: - Network Call

        URLSession.shared.dataTask(with: request) { data, _, error in

            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
                return
            }

            guard let data = data else {
                print("❌ No data received")
                DispatchQueue.main.async { completion(nil) }
                return
            }

            // MARK: - Parse Response (Safe)

            guard
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let routes = json["routes"] as? [[String: Any]],
                let firstRoute = routes.first,
                let polyline = firstRoute["polyline"] as? [String: Any],
                let encodedPath = polyline["encodedPolyline"] as? String
            else {
                let raw = String(data: data, encoding: .utf8) ?? "Empty"
                print("❌ Invalid response: \(raw)")
                DispatchQueue.main.async { completion(nil) }
                return
            }

            let path = GMSPath(fromEncodedPath: encodedPath)

            print("✅ Route fetched successfully")

            // MARK: - Always return on main thread

            DispatchQueue.main.async {
                completion(path)
            }

        }.resume()
    }
}
