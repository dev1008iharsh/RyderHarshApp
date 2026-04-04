//
//  PlaceManager.swift
//  RyderHarshApp
//
//  Created by Harsh on 04/04/26.
//

import Foundation
import GooglePlaces

final class PlaceManager {
    
    // MARK: - Properties
    
    /// Singleton instance to use throughout the app
    static let shared = PlaceManager()
    
    /// Session tokens are used to group the query and selection phases of a user search
    /// into a discrete session for billing purposes.
    private var sessionToken: GMSAutocompleteSessionToken?

    // Private initializer to prevent multiple instances
    private init() {}

    // MARK: - Public Methods

    /// Searches for place predictions based on the user's text input
    /// - Parameters:
    ///   - query: The string typed by the user (e.g., "Airport Road")
    ///   - completion: Returns an array of predictions to show in the TableView
    func searchPlaces(query: String, completion: @escaping ([GMSAutocompletePrediction]) -> Void) {
        
        // 1. Basic validation: Don't call API for empty strings
        if query.trimmingCharacters(in: .whitespaces).isEmpty {
            print("⚠️ [PlaceManager] Empty query. Skipping search.")
            completion([])
            return
        }

        // 2. Manage Session Token
        // Create a new token if it's the start of a new search session
        if sessionToken == nil {
            sessionToken = GMSAutocompleteSessionToken()
            print("🔑 [PlaceManager] New Session Token generated for billing optimization.")
        }

        // 3. Configure Filter
        // We set the type to .address to get specific delivery locations
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        
        print("🔍 [PlaceManager] Searching for: \(query)...")

        // 4. Call Google Places SDK
        GMSPlacesClient.shared().findAutocompletePredictions(
            fromQuery: query,
            filter: filter,
            sessionToken: sessionToken,
            callback: { [weak self] (results, error) in
                
                // Handle potential errors (Network, API Key, etc.)
                if let error = error {
                    print("❌ [PlaceManager] Autocomplete Error: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let predictions = results else {
                    print("⚠️ [PlaceManager] No results found for the given query.")
                    completion([])
                    return
                }

                print("✅ [PlaceManager] Found \(predictions.count) predictions.")
                completion(predictions)
            }
        )
    }
    
    /// Call this when the user selects a place or cancels the search
    /// to reset the billing session.
    func clearSession() {
        sessionToken = nil
        print("🗑️ [PlaceManager] Session Token cleared.")
    }
}
