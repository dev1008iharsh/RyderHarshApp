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
    func searchPlaces(query: String, completion: @escaping ([GMSAutocompleteSuggestion]) -> Void) {
        // 1. Basic validation: Don't call API for empty strings or just whitespace
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
        if trimmedQuery.isEmpty {
            print("⚠️ [PlaceManager] Empty query detected. Skipping API call.")
            completion([])
            return
        }

        // 2. Manage Session Token for Billing Optimization
        // If no session exists, create a new one to group keystrokes into one billing event
        if sessionToken == nil {
            sessionToken = GMSAutocompleteSessionToken()
            print("🔑 [PlaceManager] New GMSAutocompleteSessionToken generated.")
        }

        // 3. Create the New Autocomplete Request (2026 Standards)
        // We use GMSAutocompleteRequest instead of direct parameters
        let request = GMSAutocompleteRequest(query: trimmedQuery)

        // Configure Filter: Restrict results to physical addresses
        let filter = GMSAutocompleteFilter()

        filter.types = ["address"]

        // Assign filter
        request.filter = filter

        // Attach the session token
        request.sessionToken = sessionToken

        print("🔍 [PlaceManager] Requesting suggestions for: '\(trimmedQuery)'...")

        // 4. Call the modern Google Places SDK method
        // Note: 'fetchAutocompleteSuggestions' replaces the old 'findAutocompletePredictions'
        GMSPlacesClient.shared().fetchAutocompleteSuggestions(from: request) { [weak self] results, error in

            // Ensure self is still alive (Memory Safety)
            guard let _ = self else { return }

            // Handle potential errors (Network, API Key restriction, etc.)
            if let error = error {
                print("❌ [PlaceManager] Autocomplete Error: \(error.localizedDescription)")
                completion([])
                return
            }

            // Handle cases where results are nil or empty
            guard let suggestions = results, !suggestions.isEmpty else {
                print("⚠️ [PlaceManager] No suggestions found for query: '\(trimmedQuery)'.")
                completion([])
                return
            }

            // Success!
            print("✅ [PlaceManager] Successfully found \(suggestions.count) suggestions.")
            completion(suggestions)
        }
    }

    /// Call this when the user selects a place or cancels the search
    /// to reset the billing session.
    func clearSession() {
        sessionToken = nil
        print("🗑️ [PlaceManager] Session Token cleared.")
    }
}
