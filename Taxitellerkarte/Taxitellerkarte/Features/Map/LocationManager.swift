import CoreLocation
import Observation

struct LocationCoordinate: Sendable, Equatable, Hashable {
    let latitude: Double
    let longitude: Double

    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var clLocation: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}

@Observable
@MainActor
final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    var lastLocation: LocationCoordinate?
    var authStatus: CLAuthorizationStatus
    var didDeny: Bool = false

    override init() {
        self.authStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    /// Request a single location update; prompts for permission if needed.
    func requestOnce() {
        switch authStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            didDeny = true
        @unknown default:
            break
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ m: CLLocationManager) {
        let status = m.authorizationStatus
        Task { @MainActor in
            self.authStatus = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                m.requestLocation()
            } else if status == .denied || status == .restricted {
                self.didDeny = true
            }
        }
    }

    nonisolated func locationManager(_ m: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        let coord = LocationCoordinate(
            latitude: latest.coordinate.latitude,
            longitude: latest.coordinate.longitude
        )
        Task { @MainActor in
            self.lastLocation = coord
        }
    }

    nonisolated func locationManager(_ m: CLLocationManager, didFailWithError error: Error) {
        // Ignore — most common cause is "location unknown" which Core Location will retry.
    }
}
