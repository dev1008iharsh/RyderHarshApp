# 🛵 Real-Time Rider Tracking System (Blinkit Architecture)

A robust, production-grade iOS application built with **Swift** and **UIKit**. This project implements a high-fidelity rider tracking engine designed for scalability, low latency, and efficient background execution.

---

## 🌟 Key Features

* **Live Rider Tracking:** Real-time GPS tracking with a **5-meter distance filter** for precise navigation.
* **Smooth Glide Animation:** Uses `CATransaction` for frame interpolation, ensuring the bike icon glides smoothly on the map without "jumping."
* **Advanced Routing (v2):** Integration with the latest **Google Routes API (v2)** for optimized pathfinding.
* **Search Optimization:** Billing-aware location searching using **Session Tokens** and the **Google Places API**.
* **Resilient Background Mode:** Continuous tracking even when the app is minimized or the screen is locked.
* **Termination Recovery:** Leverages `Significant Location Monitoring` to restart the app in the background if force-killed by the system or user.

---

## 🛠️ Technical Stack & Architecture

### Core Technologies
* **Language:** Swift (2026 Modern Standards)
* **UI Framework:** UIKit (100% Programmatic UI)
* **Architecture:** MVC (Model-View-Controller)
* **Concurrency:** Grand Central Dispatch (GCD) for Thread Safety.

### Third-Party Integrations (Google Maps Platform)
* **Maps SDK for iOS:** For high-performance map rendering and custom `GMSMarker` handling.
* **Routes API (v2):** For lightweight, REST-based route calculations using **Field Masking**.
* **Places API (New):** For predictive address searching and coordinate fetching.

---

## 🧠 Advanced Engineering Implementation

### 1. Memory Management & Safety
To ensure the app remains crash-free and performant during long delivery shifts:
* **ARC & Retain Cycle Prevention:** Used `[weak self]` in all network and location closures to prevent memory leaks.
* **Singleton Pattern:** Centralized managers (`RiderLocationManager`, `DirectionsManager`) ensure a single source of truth and zero data duplication.

### 2. Thread Safety (GCD)
Designed to keep the UI responsive (60 FPS) even during heavy network activity:
* **Background Threading:** All API requests and heavy JSON parsing are offloaded to background threads.
* **Main Thread Dispatching:** All UI-related updates (Map markers, Polylines, TableView) are explicitly dispatched back to the `Main Thread` via `DispatchQueue.main.async`.

### 3. Professional Animation Logic
Unlike standard map apps, this system avoids choppy marker movement:
* **Interpolation:** Using 2.0-second `CATransaction` blocks to sync with GPS frequency.
* **Dynamic Course Rotation:** The marker's `rotation` property is bound to the GPS `course` (heading), making the bike icon face the direction of travel automatically.

### 4. Background & "App Killed" Persistence
Ensuring the rider is never lost:
* **Allows Background Updates:** Configured `allowsBackgroundLocationUpdates` to keep the GPS hardware active.
* **Significant Location Monitoring:** Acts as a wake-up trigger for the app in a terminated state, fulfilling real-world logistics requirements.

### 5. API Cost & Performance Optimization
* **Google Field Masking:** Only requests specific JSON fields (`routes.polyline.encodedPolyline`), reducing data usage and latency.
* **Autocomplete Session Tokens:** Groups multiple search keystrokes into a single billing event to maximize the Google Cloud free tier credits.

---

## 🛡️ Setup & Installation

1.  **Clone the Repo:** `git clone https://github.com/dev1008iharsh/RyderHarshApp.git`
2.  **Install Dependencies:** Ensure you have Google Maps and Google Places SDKs installed via Swift Package Manager (SPM).
3.  **API Keys:** Add your Google Maps API Key in `AppDelegate.swift`.
4.  **Permissions:** Ensure the following keys are in your `Info.plist`:
    * `NSLocationAlwaysAndWhenInUseUsageDescription`
    * `NSLocationWhenInUseUsageDescription`
    * `UIBackgroundModes` (Include `location`)

---

## 👨‍💻 Developed By
**Harsh**
*Senior iOS Developer specializing in Swift & SwiftUI*
GitHub: [dev1008iharsh](https://github.com/dev1008iharsh/?tab=repositories)
Contact : 91 9662108047 & dev.iharsh1008@gmail.com


---
*Developed with a focus on clean architecture, safe memory management, and 2026 industry standards.*
