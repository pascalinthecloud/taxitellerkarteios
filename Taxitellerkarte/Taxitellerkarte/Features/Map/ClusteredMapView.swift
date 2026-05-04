import SwiftUI
import MapKit

struct ClusteredMapView: UIViewRepresentable {
    struct RecenterRequest: Equatable {
        let id: UUID
        let coordinate: CLLocationCoordinate2D
        let span: MKCoordinateSpan

        static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    }

    let restaurants: [Restaurant]
    @Binding var selected: Restaurant?
    let recenter: RecenterRequest?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = false
        mapView.preferredConfiguration = MKStandardMapConfiguration()

        mapView.register(
            RestaurantMarkerView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
        mapView.register(
            MKMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier
        )

        mapView.setRegion(.germany, animated: false)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        let existing = mapView.annotations.compactMap { $0 as? RestaurantAnnotation }
        let existingIDs = Set(existing.map(\.restaurant.id))
        let targetIDs = Set(restaurants.map(\.id))

        if existingIDs != targetIDs {
            mapView.removeAnnotations(existing)
            mapView.addAnnotations(restaurants.map(RestaurantAnnotation.init(restaurant:)))
        }

        if let recenter, recenter.id != context.coordinator.lastAppliedRecenterID {
            let region = MKCoordinateRegion(center: recenter.coordinate, span: recenter.span)
            mapView.setRegion(region, animated: true)
            context.coordinator.lastAppliedRecenterID = recenter.id
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        let parent: ClusteredMapView
        var lastAppliedRecenterID: UUID?

        init(parent: ClusteredMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation as? RestaurantAnnotation {
                parent.selected = annotation.restaurant
            } else if let cluster = view.annotation as? MKClusterAnnotation {
                let region = MKCoordinateRegion(
                    center: cluster.coordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: max(mapView.region.span.latitudeDelta * 0.4, 0.005),
                        longitudeDelta: max(mapView.region.span.longitudeDelta * 0.4, 0.005)
                    )
                )
                mapView.setRegion(region, animated: true)
            }
            mapView.deselectAnnotation(view.annotation, animated: false)
        }
    }
}

extension MKCoordinateRegion {
    static let germany = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.16, longitude: 10.45),
        span: MKCoordinateSpan(latitudeDelta: 8.0, longitudeDelta: 10.0)
    )
}
