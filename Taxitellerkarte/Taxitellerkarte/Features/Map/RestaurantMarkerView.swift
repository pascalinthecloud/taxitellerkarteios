import MapKit
import UIKit

final class RestaurantMarkerView: MKMarkerAnnotationView {
    static let clusterID = "restaurant"

    override var annotation: (any MKAnnotation)? {
        didSet {
            guard let annotation = annotation as? RestaurantAnnotation else { return }
            clusteringIdentifier = Self.clusterID
            displayPriority = .defaultHigh
            canShowCallout = false

            markerTintColor = annotation.restaurant.markerTint
            glyphImage = UIImage(systemName: "fork.knife")
            glyphTintColor = .white
        }
    }
}

private extension Restaurant {
    var markerTint: UIColor {
        switch hasTaxiTeller {
        case .some(true):  UIColor(named: "AccentColor") ?? .systemRed
        case .some(false): .systemGray
        case nil:          .systemOrange
        }
    }
}
