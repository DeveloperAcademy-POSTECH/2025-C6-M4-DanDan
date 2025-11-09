//
//  MapOverlayRefresher.swift
//  DanDan
//
//  Created by soyeonsoo on 11/9/25.
//

import MapKit

enum MapOverlayRefresher {
    static func refreshColors(on mapView: MKMapView, with provider: ZoneStrokeProvider) {
        for overlay in mapView.overlays {
            guard let line = overlay as? ColoredPolyline,
                  let renderer = mapView.renderer(for: overlay) as? MKPolylineRenderer else { continue }
            renderer.strokeColor = provider.stroke(for: line.zoneId, isOutline: line.isOutline)
            renderer.setNeedsDisplay()
        }
    }
}
