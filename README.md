# 🛵 Real-Time Rider Tracking System (Blinkit Architecture)

A premium, production-grade iOS tracking engine built with **Swift** and **UIKit**. This project is designed to solve the complex challenges of real-time logistics, including background persistence, battery optimization, and smooth UI animations.

---
<img width="1408" height="768" alt="Gemini_Generated_Image_fdyil7fdyil7fdyi_50" src="https://github.com/user-attachments/assets/1093a14c-8d50-43fc-a22e-27d6b5e6a1a2" />


## 🌟 Key Features

* **Live Rider Tracking:** High-precision GPS tracking with a **5-meter distance filter**.
* **Smooth Glide Animation:** Eliminates "teleporting" markers using `CATransaction` for 60FPS fluid movement.
* **Routes API (v2) Integration:** Uses Google’s latest REST-based API with **Field Masking** for faster route plotting.
* **Smart Autocomplete:** Search for destinations with cost-optimized **Session Tokens**.
* **Background Resilience:** Maintains a "Live" connection even when the app is minimized.
* **Termination Recovery (App Kill):** Automatically wakes up the app using **Significant Location Changes (SLC)** if the rider force-closes it.

---

## 🛠️ Technical Stack & Architecture (Beginner Friendly)

### 📱 Core iOS Frameworks
* **UIKit:** Used for building the UI programmatically (No Storyboards) for better version control and performance.
* **Core Location:** The primary framework used to talk to the iPhone's GPS hardware.
* **GCD (Grand Central Dispatch):** Used to manage **Thread Safety** (keeping the UI smooth while the background does the heavy lifting).

### 🌍 Google Maps Integration
* **Maps SDK:** Renders the map and handles custom marker rotations.
* **Routes API (v2):** Fetches the path coordinates between two points.
* **Places API:** Provides a list of addresses based on user input.

---

## 🧠 Deep-Dive: How it Works (For New Developers)

If you are new to iOS, location tracking can be tricky. Here is a breakdown of the "Magic" happening inside this project:

### 1. The Background Logic: Why the Blue Pill? 🔵
When you minimize the app, iOS wants to "freeze" it to save battery. We prevent this by enabling **Background Modes**. 
* **Technique:** We set `allowsBackgroundLocationUpdates = true`.
* **Result:** iOS shows a blue indicator in the status bar, letting the user know we are still tracking to ensure their delivery is safe.

### 2. Handling the "App Kill" (Force Termination) 🛡️
Most apps stop working when you swipe them up to close. Our app uses **Significant Location Change (SLC)** monitoring. 
* **The Concept:** Even if the app is killed, the iOS system watches for a change in Cell Towers (around 500 meters).
* **The Wake-up:** Once the rider moves, iOS "re-launches" our app in the background for a few seconds—just enough time to send the new location to the server.

### 3. Smooth Animation (No More Jumping Icons!) 🛵
Normally, GPS markers "jump" from one point to another. We fixed this using **Interpolation**.
* **Logic:** When a new coordinate arrives, we use `CATransaction` to glide the marker over a **2-second duration**. 
* **Rotation:** We use `location.course` to rotate the bike icon so it always faces the direction the rider is driving.

### 4. Thread Safety: Keeping the App Fast ⚡
* **Background Thread:** We fetch the route and search results here. If we did this on the main thread, the map would "freeze" every time you type.
* **Main Thread:** All UI updates (moving the marker, drawing lines) happen here via `DispatchQueue.main.async`.

---

## 📊 Technical Comparison Table

| Feature | Standard GPS Tracking | Significant Change (SLC) |
| :--- | :--- | :--- |
| **Accuracy** | Extremely High (GPS) | Moderate (Cell Tower) |
| **Battery Impact** | Moderate to High | Very Low |
| **App-Kill Support** | No | **Yes (Wakes up app)** |
| **Required Permission** | When In Use / Always | **Always** |
| **Best Use Case** | Real-time Navigation | Emergency/App Recovery |

---

## 🛡️ Setup & Installation

1.  **Clone the Repository:**
2.  **Add API Key:** Open `AppDelegate.swift` and replace `YOUR_API_KEY` with your Google Cloud API Key.
3.  **Enable Capabilities:** Go to Project Settings -> Signing & Capabilities -> Add **Background Modes** (Select **Location updates**).
4.  **Permissions:** Ensure `Info.plist` has descriptions for `NSLocationAlwaysAndWhenInUseUsageDescription`.

---

## 📬 Contact & Support

If you have any questions or want to collaborate on iOS projects, feel free to reach out!

* **Developer:** Harsh
* **Role:** Senior iOS Engineer (Swift & UIKit Specialist)
* **Phone:** [+91 9662108047](tel:+919662108047)
* **Email:** [dev.iharsh1008@gmail.com](mailto:dev.iharsh1008@gmail.com)
* **GitHub:** [dev1008iharsh](https://github.com/dev1008iharsh)

---
*Built with ❤️ and Senior-level best practices for the developer community.*
