//
//  RoutesResponse.swift
//  RyderHarshApp
//
//  Created by Harsh on 04/04/26.
//


import Foundation

// MARK: - Response Models

struct RoutesResponse: Codable, Sendable {
    let routes: [Route]
}

struct Route: Codable, Sendable {
    let distanceMeters: Int?
    let duration: String?
    let polyline: Polyline?
}

struct Polyline: Codable, Sendable {
    let encodedPolyline: String?
}

// MARK: - Request Models

struct ComputeRoutesRequest: Codable, Sendable {
    let origin: LocationWrapper
    let destination: LocationWrapper
    let travelMode: String
    let routingPreference: String
    let computeAlternativeRoutes: Bool
    let routeModifiers: RouteModifiers
    let languageCode: String
    let units: String
}

struct LocationWrapper: Codable, Sendable {
    let location: Location
}

struct Location: Codable, Sendable {
    let latLng: LatLng
}

struct LatLng: Codable, Sendable {
    let latitude: Double
    let longitude: Double
}

struct RouteModifiers: Codable, Sendable {
    let avoidTolls: Bool
    let avoidHighways: Bool
    let avoidFerries: Bool
}
