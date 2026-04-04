//
//  RiderView.swift
//  RyderHarshApp
//
//  Created by Harsh on 04/04/26.
//

import UIKit
import GoogleMaps

final class RiderView: UIView {
    
    // MARK: - UI Elements
    
    let mapView: GMSMapView = {
        // Defaults to Rajkot/Ahmedabad area as per context
        let camera = GMSCameraPosition.camera(withLatitude: 23.0225, longitude: 72.5714, zoom: 15.0)
        let map = GMSMapView(frame: .zero, camera: camera)
        map.settings.myLocationButton = true
        map.isMyLocationEnabled = true
        return map
    }()
    
    let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Search delivery location..."
        bar.searchBarStyle = .minimal
        bar.backgroundColor = .white
        bar.layer.cornerRadius = 12
        bar.layer.shadowColor = UIColor.black.cgColor
        bar.layer.shadowOpacity = 0.1
        bar.layer.shadowOffset = CGSize(width: 0, height: 2)
        bar.layer.shadowRadius = 4
        return bar
    }()
    
    let resultsTableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.isHidden = true
        table.layer.cornerRadius = 12
        table.tableFooterView = UIView() // Removes empty cell lines
        return table
    }()
    
    let bikeMarker: GMSMarker = {
        let marker = GMSMarker()
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        // Note: 'bike_icon' must be 32x32 or 48x48 in Assets.xcassets
        marker.icon = UIImage(named: "bike_icon")
        return marker
    }()
    
    let routePolyline: GMSPolyline = {
        let line = GMSPolyline()
        line.strokeColor = .systemBlue
        line.strokeWidth = 6.0 // Made slightly thicker for better visibility
        return line
    }()

    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        // Order of adding subviews matters for layering!
        [mapView, searchBar, resultsTableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            // 1. Map: Fills the entire screen
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // 2. Search Bar: Floats at the top with safe area padding
            searchBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 15),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            searchBar.heightAnchor.constraint(equalToConstant: 55),
            
            // 3. TableView: Appears directly below the search bar
            resultsTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 5),
            resultsTableView.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
            resultsTableView.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            resultsTableView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        // Assigning map objects
        bikeMarker.map = mapView
        routePolyline.map = mapView
        
        // Ensure table view is always on top of the map
        bringSubviewToFront(resultsTableView)
        bringSubviewToFront(searchBar)
    }
}
