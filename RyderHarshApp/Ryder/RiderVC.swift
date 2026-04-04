//
//  RiderVC.swift
//  RyderHarshApp
//
//  Created by Harsh on 04/04/26.
//

import GoogleMaps
import GooglePlaces
import UIKit

final class RiderVC: UIViewController {

    // MARK: - Properties

    private let contentView = RiderView()

    /// Stores autocomplete results
    private var searchResults: [GMSAutocompleteSuggestion] = []

    /// Session token for grouping autocomplete + place requests (billing optimization)
    private var sessionToken = GMSAutocompleteSessionToken()

    // MARK: - Lifecycle

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Rider Live Tracking"

        print("🟢 RiderVC Loaded")

        setupDelegates()
        setupLocationBinding()
    }

    deinit {
        print("🔴 RiderVC Deinitialized (No Memory Leak)")
    }

    // MARK: - Setup

    private func setupDelegates() {
        contentView.searchBar.delegate = self
        contentView.resultsTableView.delegate = self
        contentView.resultsTableView.dataSource = self
    }

    private func setupLocationBinding() {
        print("📍 Starting location tracking...")

        RiderLocationManager.shared.startTracking()

        RiderLocationManager.shared.onLocationUpdate = { [weak self] location in
            guard let self else { return }
            self.animateMarker(to: location)
        }
    }

    // MARK: - Map Animation

    /// Smoothly animate rider marker
    private func animateMarker(to location: CLLocation) {
        let coordinate = location.coordinate

        print("📍 Updating rider location: \(coordinate.latitude), \(coordinate.longitude)")

        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0)

        contentView.bikeMarker.position = coordinate

        /// Rotate marker based on heading
        if location.course >= 0 {
            contentView.bikeMarker.rotation = location.course
        }

        CATransaction.commit()

        let cameraUpdate = GMSCameraUpdate.setTarget(coordinate)
        contentView.mapView.animate(with: cameraUpdate)
    }

    // MARK: - Route Drawing

    private func drawRoute(to destination: CLLocationCoordinate2D) {
        guard let riderLocation = RiderLocationManager.shared.currentLocation?.coordinate else {
            print("⚠️ Rider location missing")
            return
        }

        print("🛣️ Fetching route...")

        DirectionsManager.shared.fetchRoute(from: riderLocation, to: destination) { [weak self] path in
            guard let self, let path else {
                print("❌ Route fetch failed")
                return
            }

            DispatchQueue.main.async {
                print("✅ Drawing route on map")

                self.contentView.routePolyline.path = path

                let bounds = GMSCoordinateBounds(path: path)
                let update = GMSCameraUpdate.fit(bounds, withPadding: 100)
                self.contentView.mapView.animate(with: update)
            }
        }
    }
}

// MARK: - Search + TableView

extension RiderVC: UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    /// Called when user types in search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        guard !searchText.isEmpty else {
            print("🔍 Search cleared")

            searchResults.removeAll()

            DispatchQueue.main.async {
                self.contentView.resultsTableView.isHidden = true
                self.contentView.resultsTableView.reloadData()
            }
            return
        }

        print("🔍 Searching: \(searchText)")

        let request = GMSAutocompleteRequest(query: searchText)
        request.sessionToken = sessionToken

        GMSPlacesClient.shared().fetchAutocompleteSuggestions(from: request) { [weak self] suggestions, error in

            guard let self else { return }

            if let error {
                print("❌ Autocomplete error: \(error.localizedDescription)")
                return
            }

            self.searchResults = suggestions ?? []

            DispatchQueue.main.async {
                print("📋 Results count: \(self.searchResults.count)")

                self.contentView.resultsTableView.isHidden = self.searchResults.isEmpty
                self.contentView.resultsTableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let suggestion = searchResults[indexPath.row]

        /// Display full formatted address
        cell.textLabel?.text = suggestion.placeSuggestion?.attributedFullText.string
        cell.textLabel?.numberOfLines = 0

        return cell
    }

    /// Called when user selects a place
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let suggestion = searchResults[indexPath.row]

        guard let placeID = suggestion.placeSuggestion?.placeID else {
            print("❌ Missing placeID")
            return
        }

        print("🎯 Selected placeID: \(placeID)")

        let placeProperties = [
            GMSPlaceProperty.name.rawValue,
            GMSPlaceProperty.coordinate.rawValue
        ]

        let request = GMSFetchPlaceRequest(
            placeID: placeID,
            placeProperties: placeProperties,
            sessionToken: sessionToken
        )

        GMSPlacesClient.shared().fetchPlace(with: request) { [weak self] place, error in

            guard let self else { return }

            if let error {
                print("❌ Fetch place error: \(error.localizedDescription)")
                return
            }

            guard let coordinate = place?.coordinate else {
                print("❌ Missing coordinate")
                return
            }

            DispatchQueue.main.async {

                print("📍 Place selected: \(place?.name ?? "Unknown")")

                /// Hide results + update UI
                self.contentView.resultsTableView.isHidden = true
                self.contentView.searchBar.text = place?.name
                self.view.endEditing(true)

                /// Reset session token (VERY IMPORTANT)
                self.sessionToken = GMSAutocompleteSessionToken()

                /// Draw route
                self.drawRoute(to: coordinate)

                /// Add destination marker
                let marker = GMSMarker(position: coordinate)
                marker.title = place?.name
                marker.map = self.contentView.mapView
            }
        }
    }
}
