import MapKit
import SwiftUI
import UIKit

private extension UIColor {
    static var ilCyan: UIColor {
        UIColor(red: 0, green: 0.784, blue: 0.878, alpha: 1)
    }
}

final class ILSpotAnnotation: NSObject, MKAnnotation {
    let spotId: String
    dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?

    init(spotId: String, coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.spotId = spotId
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        super.init()
    }
}

struct ILMapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    /// Explicit `Binding` so `Coordinator` can write selection without stale `@Binding` projection issues.
    var selectedSpotId: Binding<String?>
    var mapType: MKMapType
    var showUserLocation: Bool
    var spots: [ILSpot]
    var speciesName: (String) -> String?
    var onLongPress: (CLLocationCoordinate2D) -> Void

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.region = region
        map.delegate = context.coordinator
        map.mapType = mapType
        map.showsUserLocation = showUserLocation
        map.isRotateEnabled = false
        map.pointOfInterestFilter = .excludingAll
        context.coordinator.lastRegion = region
        let lp = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(_:)))
        lp.minimumPressDuration = 0.5
        map.addGestureRecognizer(lp)
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        context.coordinator.parent = self
        map.mapType = mapType
        map.showsUserLocation = showUserLocation
        if !regionsApproximatelyEqual(context.coordinator.lastRegion, region) {
            context.coordinator.isApplyingProgrammaticRegion = true
            map.setRegion(region, animated: false)
            context.coordinator.isApplyingProgrammaticRegion = false
            context.coordinator.lastRegion = region
        }
        syncAnnotations(map)
        if let sid = selectedSpotId.wrappedValue, !spots.contains(where: { $0.id == sid }) {
            selectedSpotId.wrappedValue = nil
            map.selectedAnnotations.forEach { map.deselectAnnotation($0, animated: false) }
        }
    }

    private func syncAnnotations(_ map: MKMapView) {
        let existing = map.annotations.compactMap { $0 as? ILSpotAnnotation }
        let ids = Set(spots.map(\.id))
        for ann in existing where !ids.contains(ann.spotId) {
            map.removeAnnotation(ann)
        }
        for sp in spots {
            if let ann = existing.first(where: { $0.spotId == sp.id }) {
                ann.coordinate = CLLocationCoordinate2D(latitude: sp.latitude, longitude: sp.longitude)
                ann.title = sp.name
                let fish = sp.speciesId.flatMap { speciesName($0) } ?? ""
                ann.subtitle = fish.isEmpty ? ILDateFormatting.displayDate(fromISO: sp.date) : fish
            } else {
                let fish = sp.speciesId.flatMap { speciesName($0) } ?? ""
                let ann = ILSpotAnnotation(
                    spotId: sp.id,
                    coordinate: CLLocationCoordinate2D(latitude: sp.latitude, longitude: sp.longitude),
                    title: sp.name,
                    subtitle: fish.isEmpty ? ILDateFormatting.displayDate(fromISO: sp.date) : fish
                )
                map.addAnnotation(ann)
            }
        }
    }

    private func regionsApproximatelyEqual(_ a: MKCoordinateRegion, _ b: MKCoordinateRegion) -> Bool {
        abs(a.center.latitude - b.center.latitude) < 0.00001
            && abs(a.center.longitude - b.center.longitude) < 0.00001
            && abs(a.span.latitudeDelta - b.span.latitudeDelta) < 0.00001
            && abs(a.span.longitudeDelta - b.span.longitudeDelta) < 0.00001
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: ILMapViewRepresentable
        var isApplyingProgrammaticRegion = false
        var lastRegion: MKCoordinateRegion = .init()

        init(_ parent: ILMapViewRepresentable) {
            self.parent = parent
        }

        @objc func handleLongPress(_ gr: UILongPressGestureRecognizer) {
            guard gr.state == .began, let map = gr.view as? MKMapView else { return }
            let pt = gr.location(in: map)
            let coord = map.convert(pt, toCoordinateFrom: map)
            ILHaptics.medium()
            parent.onLongPress(coord)
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            if isApplyingProgrammaticRegion { return }
            lastRegion = mapView.region
            parent.region = mapView.region
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }
            guard let ann = annotation as? ILSpotAnnotation else { return nil }
            let id = "spot"
            let v = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView
                ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
            v.annotation = ann
            v.canShowCallout = false
            v.markerTintColor = .ilCyan
            let sp = parent.spots.first { $0.id == ann.spotId }
            v.glyphImage = UIImage(systemName: sp?.speciesId != nil ? "fish.fill" : "mappin")
            v.rightCalloutAccessoryView = nil
            return v
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let ann = view.annotation as? ILSpotAnnotation else { return }
            DispatchQueue.main.async { [weak self] in
                self?.parent.selectedSpotId.wrappedValue = ann.spotId
            }
        }

        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            guard let ann = view.annotation as? ILSpotAnnotation else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if self.parent.selectedSpotId.wrappedValue == ann.spotId {
                    self.parent.selectedSpotId.wrappedValue = nil
                }
            }
        }
    }
}
