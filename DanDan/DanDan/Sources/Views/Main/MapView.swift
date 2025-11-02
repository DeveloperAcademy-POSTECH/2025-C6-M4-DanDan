//
//  MapView.swift
//  DanDan
//
//  Created by soyeonsoo on 10/26/25.
//

import SwiftUI
import MapKit

// 부분 3D 지도(메인)
struct MapView: UIViewRepresentable {
    
    // MARK: - Bounds
    /// 철길숲의 남서쪽과 북동쪽 좌표를 기준으로 지도 표시 범위를 계산하는 내부 구조체
    private struct Bounds {
        let southWest: CLLocationCoordinate2D
        let northEast: CLLocationCoordinate2D
        let margin: Double = 0.55
        
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
        
        var span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    }
    
    // MARK: - Constants
    /// 실제 철길숲 남서쪽과 북동쪽 경계 좌표
    private let bounds = Bounds(
        southWest: .init(latitude: 35.998605, longitude: 129.316145),
        northEast: .init(latitude: 36.057920, longitude: 129.361197)
    )
    
    // MARK: - Overlays
    final class ColoredPolyline: MKPolyline {
        var color: UIColor = .white
    }
    
    // MARK: - Coordinator
    final class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        let manager = CLLocationManager()
        weak var mapView: MKMapView?
        
        override init() {
            super.init()
            manager.delegate = self
        }
        
        func request() {
            manager.requestWhenInUseAuthorization() // 위치 정보 접근 권한 요청
            manager.startUpdatingLocation() // 위치 업데이트 시작
            manager.startUpdatingHeading() // 나침반(방향) 업데이트 시작
        }
        
        // 사용자의 위치에 따라 카메라 중심 이동
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let mapView = mapView,
                  let location = locations.last else { return }
            
            let camera = MKMapCamera(
                lookingAtCenter: location.coordinate,
                fromDistance: 800,
                pitch: 80,
                heading: mapView.camera.heading
            )
            mapView.setCamera(camera, animated: true)
        }
        
        // 유저의 방향(heading) 변경에 따라 지도 회전
        func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
            guard let mapView = mapView else { return }
            
            let currentCenter = mapView.camera.centerCoordinate
            let camera = MKMapCamera(
                lookingAtCenter: currentCenter,
                fromDistance: 800,
                pitch: 80,
                heading: newHeading.trueHeading
            )
            mapView.setCamera(camera, animated: true)
        }
        
        // Polyline renderer
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let line = overlay as? ColoredPolyline {
                let renderer = MKPolylineRenderer(overlay: line)
                renderer.strokeColor = line.color
                renderer.lineWidth = 20
                renderer.lineCap = .butt
                renderer.lineJoin = .round
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        
        map.isScrollEnabled = false
        map.isZoomEnabled = false
        map.isRotateEnabled = false
        map.isPitchEnabled = false
        map.showsCompass = false
        
        let config = MKStandardMapConfiguration(elevationStyle: .realistic)
        config.pointOfInterestFilter = .excludingAll
        config.showsTraffic = false
        map.preferredConfiguration = config
        
        map.delegate = context.coordinator
        context.coordinator.mapView = map
        
        for zone in zones {
            let coords = [zone.zoneStartPoint, zone.zoneEndPoint]
            let polyline = ColoredPolyline(coordinates: coords, count: 2)
            polyline.color = zone.zoneColor
            map.addOverlay(polyline, level: .aboveRoads)
        }
        
        let region = bounds.region
        map.setRegion(region, animated: true)
        let camera = MKMapCamera(
            lookingAtCenter: bounds.center,
            fromDistance: 800,
            pitch: 80,
            heading: 0
        )
        map.setCamera(camera, animated: false)
        
        map.showsUserLocation = true
        context.coordinator.request()
        
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
