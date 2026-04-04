import Foundation
import CoreLocation

/// This class manages all location-related tasks for the Rider.
/// It uses a Singleton pattern to ensure only one instance handles location updates.
final class RiderLocationManager: NSObject {
    
    // MARK: - Properties
    
    /// Static shared instance to access this class globally
    static let shared = RiderLocationManager()
    
    /// The built-in iOS Location Manager service
    private let manager = CLLocationManager()
    
    /// Holds the most recent location coordinates of the Rider
    private(set) var currentLocation: CLLocation?
    
    /// A closure (callback) that notifies the View Controller when the location changes
    var onLocationUpdate: ((CLLocation) -> Void)?
    
    // MARK: - Initializer
    
    private override init() {
        super.init()
        print("📍 [LocationManager] Initializing Setup...")
        setupManager()
    }
    
    // MARK: - Setup
    
    private func setupManager() {
        manager.delegate = self
        
        // Use 'BestForNavigation' to get the most accurate GPS data (Essential for Riders)
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        // distanceFilter = 5 means the app gets an update only after the rider moves 5 meters.
        // This prevents the UI from flickering and saves battery.
        manager.distanceFilter = 5
        
        // CRITICAL: Allows the app to keep receiving locations even if the user minimizes it.
        manager.allowsBackgroundLocationUpdates = true
        
        // Prevents iOS from 'sleeping' the location service if the rider stops at a signal.
        manager.pausesLocationUpdatesAutomatically = false
        
        // Shows a blue indicator/pill in the iPhone status bar when tracking in background.
        manager.showsBackgroundLocationIndicator = true
        
        print("⚙️ [LocationManager] Manager Configured: Background Updates Enabled.")
    }
    
    // MARK: - Public Methods
    
    /// Starts the location tracking process and handles permissions
    func startTracking() {
        let status = manager.authorizationStatus
        print("🔐 [LocationManager] Current Permission Status: \(status.rawValue)")
        
        if status == .notDetermined {
            // Ask for 'Always' so we can track even if the app is killed/closed
            print("ℹ️ [LocationManager] Requesting 'Always' Authorization...")
            manager.requestAlwaysAuthorization()
        } else if status == .authorizedAlways || status == .authorizedWhenInUse {
            print("🚀 [LocationManager] Starting Standard Location Updates...")
            manager.startUpdatingLocation()
            
            // This is the 'Safety Net'. If the app is force-killed by the user,
            // this service helps wake up the app when the rider moves a significant distance.
            manager.startMonitoringSignificantLocationChanges()
            print("🛡️ [LocationManager] Significant Location Monitoring Started.")
        } else {
            print("❌ [LocationManager] Permission Denied or Restricted.")
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension RiderLocationManager: CLLocationManagerDelegate {
    
    /// This method is called by iOS every time new coordinates are available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Update our local storage with the new location
        self.currentLocation = location
        
        print("📍 [LocationManager] Update Received: Lat \(location.coordinate.latitude), Lng \(location.coordinate.longitude)")
        
        // UI updates must happen on the Main Thread to avoid crashes
        DispatchQueue.main.async { [weak self] in
            // Notify our 'RiderVC' about the new location
            self?.onLocationUpdate?(location)
        }
        
        /* PRO TIP:
         In a real Blinkit-like app, this is where you would call an API
         to send the rider's Lat/Long to your backend server so the
         customer can see the 'Live' movement on their phone.
        */
    }
    
    /// Triggered when the user changes location permissions in iOS Settings
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        print("🔐 [LocationManager] Authorization Status Changed to: \(status.rawValue)")
        
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    /// Called if there is an error retrieving the location (e.g., GPS signal lost)
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ [LocationManager] Error Encountered: \(error.localizedDescription)")
    }
}
