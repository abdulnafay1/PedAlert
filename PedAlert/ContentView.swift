import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
    var userName: String
    @StateObject private var locationManager = RealLocationManager()
    @State private var showAlert = false

    // Initial region centered on Georgia Ave NW near Howard University
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.9215, longitude: -77.0220),
        span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
    )

    // Crosswalk locations near Howard University
    private let crosswalks = [
        IdentifiableLocation(id: UUID(), coordinate: CLLocationCoordinate2D(latitude: 38.922639, longitude: -77.019278)),
        IdentifiableLocation(id: UUID(), coordinate: CLLocationCoordinate2D(latitude: 38.922750, longitude: -77.019400)),
        IdentifiableLocation(id: UUID(), coordinate: CLLocationCoordinate2D(latitude: 38.922520, longitude: -77.019100)),
        IdentifiableLocation(id: UUID(), coordinate: CLLocationCoordinate2D(latitude: 38.922630, longitude: -77.019000)),
        IdentifiableLocation(id: UUID(), coordinate: CLLocationCoordinate2D(latitude: 38.922480, longitude: -77.019300)),
        IdentifiableLocation(id: UUID(), coordinate: CLLocationCoordinate2D(latitude: 38.921028, longitude: -77.022083)),
        IdentifiableLocation(id: UUID(), coordinate: CLLocationCoordinate2D(latitude: 38.920972, longitude: -77.022194)),
        IdentifiableLocation(id: UUID(), coordinate: CLLocationCoordinate2D(latitude: 38.920889, longitude: -77.021944))
    ]

    var body: some View {
        ZStack(alignment: .top) {
            // Full-screen Map
            Map(coordinateRegion: $region, annotationItems: crosswalks) { location in
                MapMarker(coordinate: location.coordinate, tint: .red)
            }
            .ignoresSafeArea()

            // Top banner text
            Text("You are being tracked for safety")
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(12)
                .background(Color.black.opacity(0.7))
                .cornerRadius(20)
                .padding(.top, 50)
        }
        .alert("⚠️ You're on a crosswalk", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please stop using your phone while crossing.")
        }
        .onChange(of: locationManager.location) { newLocation in
            guard let userLoc = newLocation else { return }

            // Recenter on the user's updated location
            region.center = userLoc.coordinate

            // Check distance to each crosswalk
            for crosswalk in crosswalks {
                let crosswalkLoc = CLLocation(latitude: crosswalk.coordinate.latitude, longitude: crosswalk.coordinate.longitude)
                if userLoc.distance(from: crosswalkLoc) < 20 {
                    showAlert = true
                    return
                }
            }

            showAlert = false
        }
        .onAppear {
            locationManager.requestPermission()
        }
    }
}

// MARK: - Identifiable Crosswalk Location
struct IdentifiableLocation: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
}
