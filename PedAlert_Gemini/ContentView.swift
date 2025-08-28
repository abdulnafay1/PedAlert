import SwiftUI
import CoreLocation
import UserNotifications
import MapKit // <-- IMPORTANT: Import MapKit

// --- Main App Entry Point ---
@main
struct CrosswalkGuardianApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// --- Data Model for Map Annotations ---
struct CrosswalkLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

// --- Main ContentView (The UI) ---
struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                ForEach(locationManager.crosswalks) { crosswalk in
                    Marker(crosswalk.name, systemImage: "figure.walk.diamond.fill", coordinate: crosswalk.coordinate)
                        .tint(.yellow)
                }
                UserAnnotation()
            }
            .ignoresSafeArea()

            VStack {
                Spacer()
                VStack(spacing: 20) {
                    Text("PedAlert")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    VStack(alignment: .leading, spacing: 12) {
                         HStack {
                            Image(systemName: locationManager.isNearCrosswalk ? "exclamationmark.triangle.fill" : "checkmark.seal.fill")
                                .font(.title2)
                                .foregroundColor(locationManager.isNearCrosswalk ? .yellow : .green)
                            Text(locationManager.statusMessage)
                                .font(.headline)
                                .animation(nil, value: locationManager.statusMessage)
                        }
                        
                        Divider()

                        HStack {
                            Image(systemName: "location.circle.fill")
                                .foregroundColor(.gray)
                            Text(locationManager.authorizationStatus)
                        }

                        if let location = locationManager.userLocation {
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.gray)
                                Text("Lat: \(location.coordinate.latitude, specifier: "%.4f"), Lon: \(location.coordinate.longitude, specifier: "%.4f")")
                            }
                        }
                    }
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
                .padding()
            }
        }
        .onReceive(locationManager.$userLocation.dropFirst()) { location in
            guard let location = location else { return }
            withAnimation {
                cameraPosition = .region(MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                ))
            }
        }
    }
}


// --- LocationManager (The Brains of the App) ---
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    
    // Use our new Identifiable struct for the map
    private(set) var crosswalks: [CrosswalkLocation] = [
        CrosswalkLocation(name: "Georgia Ave", coordinate: CLLocationCoordinate2D(latitude: 38.920959, longitude: -77.022056))
    ]
    
    private let alertDistance: CLLocationDistance = 25.0
    
    @Published var userLocation: CLLocation?
    @Published var statusMessage: String = "Monitoring for crosswalks..."
    @Published var authorizationStatus: String = "Not Determined"
    @Published var isNearCrosswalk: Bool = false

    private var lastNotifiedCrosswalk: CLLocation? = nil

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.showsBackgroundLocationIndicator = true
        setupAndRequestPermissions()
    }

    private func setupAndRequestPermissions() {
        requestNotificationPermission()
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            authorizationStatus = "Location Authorized"
            locationManager.startUpdatingLocation()
        case .notDetermined:
            authorizationStatus = "Requesting Location..."
            locationManager.requestAlwaysAuthorization() // Request Always for background features
        case .denied, .restricted:
            authorizationStatus = "Location Denied"
            statusMessage = "Please enable location services in Settings."
        @unknown default:
            fatalError("Unhandled CoreLocation authorization status")
        }
    }
    
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }
        DispatchQueue.main.async {
            self.userLocation = latestLocation
            self.checkProximityToCrosswalks(userLocation: latestLocation)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        setupAndRequestPermissions()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.statusMessage = "Failed to get location."
        }
    }
    
    private func checkProximityToCrosswalks(userLocation: CLLocation) {
        var foundNearby = false
        for crosswalk in crosswalks {
            let crosswalkLocation = CLLocation(latitude: crosswalk.coordinate.latitude, longitude: crosswalk.coordinate.longitude)
            let distance = userLocation.distance(from: crosswalkLocation)
            
            if distance <= alertDistance {
                if let lastNotified = lastNotifiedCrosswalk, lastNotified.distance(from: crosswalkLocation) < 1 {
                    // Still near the same crosswalk
                } else {
                    sendProximityNotification()
                    self.lastNotifiedCrosswalk = crosswalkLocation
                }
                
                DispatchQueue.main.async {
                    self.statusMessage = "Approaching crosswalk! Be alert."
                    self.isNearCrosswalk = true
                }
                foundNearby = true
                break
            }
        }
        
        if !foundNearby {
            if let lastNotified = lastNotifiedCrosswalk, userLocation.distance(from: lastNotified) > alertDistance * 2 {
                self.lastNotifiedCrosswalk = nil
            }
            
            DispatchQueue.main.async {
                self.statusMessage = "All clear. Monitoring..."
                self.isNearCrosswalk = false
            }
        }
    }

    private func sendProximityNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Crosswalk Alert!"
        content.body = "You are approaching a crosswalk. Please be aware of your surroundings."
        content.sound = UNNotificationSound.defaultCritical
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
