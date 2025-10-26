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
    /// 철길숲의 남서쪽(start)과 북동쪽(end) 좌표를 기준으로
    /// 지도 표시 범위를 계산하는 내부 구조체
    private struct Bounds {
        let start: CLLocationCoordinate2D
        let end: CLLocationCoordinate2D
        let margin: Double = 1.01
        
        var center: CLLocationCoordinate2D {
            CLLocationCoordinate2D(
                latitude: (start.latitude + end.latitude) / 2.0,
                longitude: (start.longitude + end.longitude) / 2.0
            )
        }
        
        var region: MKCoordinateRegion {
            let spanLat = abs(end.latitude - start.latitude) * margin
            let spanLon = abs(end.longitude - start.longitude) * margin
            return MKCoordinateRegion(
                center: self.center,
                span: MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon)
            )
        }
    }
    
    // MARK: - Constants
    /// 실제 철길숲 남서쪽과 북동쪽 경계 좌표
    private let bounds = Bounds(
        start: .init(latitude: 36.018254, longitude: 129.316296),
        end: .init(latitude: 36.030950, longitude: 129.360462)
    )
    
    /// 지도 경계 제한 설정 (지도 중심이 철길숲 영역 밖으로 나가지 않도록)
    private func applyBoundary(to map: MKMapView) {
        let boundary = MKMapView.CameraBoundary(coordinateRegion: bounds.region)
        map.setCameraBoundary(boundary, animated: false)
    }
    
    /// 지도 축소 한도 설정 (철길숲 전체가 보일 정도까지만 축소)
    private func applyZoomOutLimit(to map: MKMapView, for region: MKCoordinateRegion) {
        let metersPerDegLat: CLLocationDistance = 111_000
        let metersPerDegLon: CLLocationDistance = cos(region.center.latitude * .pi/180) * 111_000
        let widthMeters  = region.span.longitudeDelta * metersPerDegLon
        let heightMeters = region.span.latitudeDelta  * metersPerDegLat
        let maxDistance = max(widthMeters, heightMeters) * 5

        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: maxDistance)
        map.setCameraZoomRange(zoomRange, animated: false)
    }
    
    // MARK: - Location Authorization
    /// CLLocationManager를 사용해 권한 요청을 수행하는 Coordinator
    final class Coordinator: NSObject, CLLocationManagerDelegate {
        let manager = CLLocationManager()
        override init() {
            super.init()
            manager.delegate = self
        }
        func request() {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        
        let region = bounds.region
        map.setRegion(region, animated: false)
        applyBoundary(to: map)
        applyZoomOutLimit(to: map, for: region)
        
        context.coordinator.request()
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
