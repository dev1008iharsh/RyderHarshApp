import Foundation
import CoreLocation
import GoogleMaps

final class DirectionsManager {
    
    static let shared = DirectionsManager()
    private init() {}
    
    /// Fetches route using the latest Google Routes API v2 standards
    func fetchRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping (GMSPath?) -> Void) {
        
        let apiKey = ""
        let urlString = "https://routes.googleapis.com/directions/v2:computeRoutes"
        
        guard let url = URL(string: urlString) else {
            print("❌ [DirectionsManager] Error: Invalid URL")
            completion(nil)
            return
        }
        
        // 1. Request Body mapping exactly with your CURL example
        let parameters: [String: Any] = [
            "origin": [
                "location": [
                    "latLng": [
                        "latitude": origin.latitude,
                        "longitude": origin.longitude
                    ]
                ]
            ],
            "destination": [
                "location": [
                    "latLng": [
                        "latitude": destination.latitude,
                        "longitude": destination.longitude
                    ]
                ]
            ],
            "travelMode": "DRIVE",
            "routingPreference": "TRAFFIC_AWARE",
            "computeAlternativeRoutes": false,
            "routeModifiers": [
                "avoidTolls": false,
                "avoidHighways": false,
                "avoidFerries": false
            ],
            "languageCode": "en-US",
            "units": "METRIC"
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // 2. Setting up Headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        
        // CRITICAL: Updated FieldMask based on your documentation reference
        request.addValue("routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline", forHTTPHeaderField: "X-Goog-FieldMask")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            print("❌ [DirectionsManager] Error: Serialization failed")
            completion(nil)
            return
        }
        
        print("🌐 [DirectionsManager] Requesting route...")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ [DirectionsManager] Network Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("❌ [DirectionsManager] No data received")
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    
                    // 3. Optimized Parsing for the new JSON structure
                    if let routes = json["routes"] as? [[String: Any]], let firstRoute = routes.first {
                        
                        // Accessing polyline -> encodedPolyline as per your FieldMask
                        if let polyline = firstRoute["polyline"] as? [String: Any],
                           let encodedPath = polyline["encodedPolyline"] as? String {
                            
                            print("✅ [DirectionsManager] Route polyline received successfully.")
                            let path = GMSPath(fromEncodedPath: encodedPath)
                            completion(path)
                        } else {
                            print("⚠️ [DirectionsManager] Path data missing in response.")
                            completion(nil)
                        }
                    } else {
                        // Debug: Print full response if no routes found (e.g., API key error)
                        let responseStr = String(data: data, encoding: .utf8) ?? "Empty"
                        print("❌ [DirectionsManager] API Error Response: \(responseStr)")
                        completion(nil)
                    }
                }
            } catch {
                print("❌ [DirectionsManager] Parsing Error: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
}
