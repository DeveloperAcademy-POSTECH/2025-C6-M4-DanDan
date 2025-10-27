//
//  MapView.swift
//  DanDan
//
//  Created by soyeonsoo on 10/26/25.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    // MARK: - Bounds
    /// 철길숲의 남서쪽과 북동쪽 좌표를 기준으로 지도 표시 범위를 계산하는 내부 구조체
    private struct Bounds {
        let southWest: CLLocationCoordinate2D
        let northEast: CLLocationCoordinate2D
        let margin: Double = 1.15
        
        var center: CLLocationCoordinate2D {
            CLLocationCoordinate2D(
                latitude: (southWest.latitude + northEast.latitude) / 2.0,
                longitude: (southWest.longitude + northEast.longitude) / 2.0
            )
        }
        
        var region: MKCoordinateRegion {
            let spanLat = abs(northEast.latitude - southWest.latitude) * margin
            let spanLon = abs(northEast.longitude - southWest.longitude) * margin
            return MKCoordinateRegion(
                center: self.center,
                span: MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon)
            )
        }
    }
    
    // MARK: - Constants
    /// 실제 철길숲 남서쪽과 북동쪽 경계 좌표
    private let bounds = Bounds(
        southWest: .init(latitude: 36.001279, longitude: 129.314454),
        northEast: .init(latitude: 36.057920, longitude: 129.361197)
    )
    
    }
    
    final class Coordinator: NSObject, CLLocationManagerDelegate, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let ann = annotation as? ZoneAnnotation else { return nil }

        }
    }
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.isScrollEnabled = false
        map.isZoomEnabled = false
        map.isRotateEnabled = false
        map.isPitchEnabled = false
        
        let region = bounds.region
        map.setRegion(region, animated: false)
        
        map.showsUserLocation = true
        
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) { }
}

struct ForailMapScreen: View {
    var body: some View {
        MapView()
            .ignoresSafeArea()
    }
}
