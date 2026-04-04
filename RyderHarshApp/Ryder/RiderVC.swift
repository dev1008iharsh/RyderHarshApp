import UIKit
import GoogleMaps
import GooglePlaces

/// The Main Controller that manages the Map UI, Rider Tracking, and Destination Search.
final class RiderVC: UIViewController {
    
    // MARK: - Properties
    
    /// The custom view containing the Google Map and Search UI
    private let contentView = RiderView()
    
    /// Array to store search predictions from Google Places
    private var searchResults: [GMSAutocompletePrediction] = []

    // MARK: - Lifecycle
    
    override func loadView() {
        // Set our custom programmatic view as the root view
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Rider Live Tracking"
        
        setupDelegates()
        setupLocationBinding()
        print("🖥️ [RiderVC] View Loaded. Delegates and Bindings initialized.")
    }

    // MARK: - Setup Methods
    
    private func setupDelegates() {
        contentView.searchBar.delegate = self
        contentView.resultsTableView.delegate = self
        contentView.resultsTableView.dataSource = self
    }
    
    private func setupLocationBinding() {
        // Start the location service
        RiderLocationManager.shared.startTracking()
        
        // Listen for real-time location updates from the Manager
        RiderLocationManager.shared.onLocationUpdate = { [weak self] location in
            guard let self = self else { return }
            
            // Log for debugging
            print("📍 [RiderVC] Location Update: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            
            // Trigger smooth animation to the new coordinate
            self.animateMarker(to: location)
        }
    }
    
    // MARK: - Animation Logic
    
    /// Smoothly glides the rider's marker and rotates it based on movement direction.
    private func animateMarker(to location: CLLocation) {
        let coordinate = location.coordinate
        
        // 1. Core Animation Transaction for professional smoothness
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0) // Glide duration (matches distanceFilter timing)
        
        // Update Marker Position
        contentView.bikeMarker.position = coordinate
        
        // 2. Update Rotation (Heading)
        // 'course' gives the direction of travel (0-360 degrees)
        if location.course >= 0 {
            print("🔄 [RiderVC] Rotating Marker to Heading: \(location.course)°")
            contentView.bikeMarker.rotation = location.course
        }
        
        CATransaction.commit()
        
        /* OPTIONAL: If you want the camera to always follow the rider:
         let cameraUpdate = GMSCameraUpdate.setTarget(coordinate)
         contentView.mapView.animate(with: cameraUpdate)
        */
        
        print("🛵 [RiderVC] Rider Marker Animated successfully.")
    }

    // MARK: - Routing Logic
    
    /// Fetches and draws the polyline route from Rider to Destination.
    private func drawRoute(to destination: CLLocationCoordinate2D) {
        // Get the last known location of the rider
        guard let riderLocation = RiderLocationManager.shared.currentLocation?.coordinate else {
            print("⚠️ [RiderVC] Cannot draw route: Rider's current location is missing.")
            return
        }
        
        print("🛣️ [RiderVC] Requesting route from Directions API...")
        
        DirectionsManager.shared.fetchRoute(from: riderLocation, to: destination) { [weak self] path in
            guard let self = self, let path = path else {
                print("❌ [RiderVC] Failed to retrieve route path.")
                return
            }
            
            // UI updates must happen on the main thread
            DispatchQueue.main.async {
                print("✨ [RiderVC] Drawing Polyline with \(path.count()) points.")
                
                // Set the path to our GMSPolyline object
                self.contentView.routePolyline.path = path
                
                // Fit the map camera to show the entire route
                let bounds = GMSCoordinateBounds(path: path)
                let update = GMSCameraUpdate.fit(bounds, withPadding: 100.0)
                self.contentView.mapView.animate(with: update)
            }
        }
    }
}

// MARK: - Search & TableView Extensions

extension RiderVC: UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // Called as the user types in the search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchResults = []
            contentView.resultsTableView.isHidden = true
            contentView.resultsTableView.reloadData()
            return
        }
        
        print("🔍 [RiderVC] Searching Places for: \(searchText)")
        
        PlaceManager.shared.searchPlaces(query: searchText) { [weak self] predictions in
            guard let self = self else { return }
            self.searchResults = predictions
            
            DispatchQueue.main.async {
                self.contentView.resultsTableView.isHidden = predictions.isEmpty
                self.contentView.resultsTableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let prediction = searchResults[indexPath.row]
        
        // Full address string from Google Prediction
        cell.textLabel?.text = prediction.attributedFullText.string
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = .systemFont(ofSize: 14)
        return cell
    }

    // Called when a user selects a destination from the list
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let prediction = searchResults[indexPath.row]
        print("🎯 [RiderVC] Selected Destination: \(prediction.attributedPrimaryText.string)")
        
        // Fetch detailed coordinates for the selected PlaceID
        GMSPlacesClient.shared().fetchPlace(fromPlaceID: prediction.placeID, placeFields: [.coordinate, .name], sessionToken: nil) { [weak self] (place, error) in
            
            if let error = error {
                print("❌ [RiderVC] Fetch Place Error: \(error.localizedDescription)")
                return
            }
            
            guard let self = self, let coordinate = place?.coordinate else { return }
            print("✅ [RiderVC] Destination Coordinates: \(coordinate.latitude), \(coordinate.longitude)")
            
            DispatchQueue.main.async {
                // UI Cleanup
                self.contentView.resultsTableView.isHidden = true
                self.contentView.searchBar.text = place?.name
                self.view.endEditing(true)
                
                // Clear billing session and draw the route
                PlaceManager.shared.clearSession()
                self.drawRoute(to: coordinate)
                
                // Add a Red Marker at the destination
                let marker = GMSMarker(position: coordinate)
                marker.title = place?.name
                marker.icon = GMSMarker.markerImage(with: .red)
                marker.map = self.contentView.mapView
                
                print("🏁 [RiderVC] Destination marker set and routing started.")
            }
        }
    }
}
