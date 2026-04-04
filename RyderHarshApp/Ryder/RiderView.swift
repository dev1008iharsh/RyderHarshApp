//
//  RiderView.swift
//  RyderHarshApp
//
//  Created by Harsh on 04/04/26.
//


import GoogleMaps
import UIKit

final class RiderView: UIView {

    // MARK: - UI Elements

    /// Main Google Map View
    let mapView: GMSMapView = {
        let options = GMSMapViewOptions()

        // Default camera (Ahmedabad area)
        options.camera = GMSCameraPosition.camera(
            withLatitude: 23.0225,
            longitude: 72.5714,
            zoom: 15.0
        )

        let map = GMSMapView(options: options)

        // Enable user location features
        map.settings.myLocationButton = true
        map.isMyLocationEnabled = true

        print("🗺️ MapView initialized")

        return map
    }()

    /// Search bar for destination input
    let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Search delivery location..."
        bar.searchBarStyle = .minimal
        bar.backgroundColor = .white

        // UI Styling
        bar.layer.cornerRadius = 12
        bar.layer.masksToBounds = false

        // Shadow for floating effect
        bar.layer.shadowColor = UIColor.black.cgColor
        bar.layer.shadowOpacity = 0.1
        bar.layer.shadowOffset = CGSize(width: 0, height: 2)
        bar.layer.shadowRadius = 4

        print("🔍 SearchBar initialized")

        return bar
    }()

    /// TableView for showing search results
    let resultsTableView: UITableView = {
        let table = UITableView()

        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        table.isHidden = true
        table.layer.cornerRadius = 12
        table.clipsToBounds = true

        // Remove empty separators
        table.tableFooterView = UIView()

        print("📋 Results TableView initialized")

        return table
    }()

    /// Rider marker (bike icon)
    let bikeMarker: GMSMarker = {
        let marker = GMSMarker()

        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)

        // Ensure asset exists (fallback safe)
        if let image = UIImage(named: "bike_icon") {
            marker.icon = image
        } else {
            print("⚠️ bike_icon not found in Assets")
        }

        return marker
    }()

    /// Route polyline
    let routePolyline: GMSPolyline = {
        let line = GMSPolyline()

        line.strokeColor = .systemBlue
        line.strokeWidth = 6.0

        return line
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("❌ init(coder:) has not been implemented")
    }

    deinit {
        print("🔴 RiderView Deinitialized (No Memory Leak)")
    }

    // MARK: - UI Setup

    private func setupUI() {

        backgroundColor = .systemBackground

        print("⚙️ Setting up RiderView UI")

        // Add subviews
        [mapView, searchBar, resultsTableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        // MARK: - Constraints

        NSLayoutConstraint.activate([

            // Map fills entire screen
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Search bar at top
            searchBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 15),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            searchBar.heightAnchor.constraint(equalToConstant: 55),

            // Results below search bar
            resultsTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 5),
            resultsTableView.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
            resultsTableView.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            resultsTableView.heightAnchor.constraint(equalToConstant: 300)
        ])

        // MARK: - Map Attachments

        /// Attach marker & polyline to map
        bikeMarker.map = mapView
        routePolyline.map = mapView

        // Ensure UI layering (important)
        bringSubviewToFront(resultsTableView)
        bringSubviewToFront(searchBar)

        print("✅ RiderView UI Setup Complete")
    }
}
