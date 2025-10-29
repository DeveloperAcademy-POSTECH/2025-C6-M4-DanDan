//
//  MapView.swift
//  DanDan
//
//  Created by soyeonsoo on 10/26/25.
//

import SwiftUI
import MapKit

final class HostingAnnotationView: MKAnnotationView {
    private var host: UIHostingController<AnyView>?

    func setSwiftUIView<Content: View>(_ view: Content) {
        if host == nil {
            let controller = UIHostingController(rootView: AnyView(view))
            controller.view.backgroundColor = .clear
            host = controller
            addSubview(controller.view)
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                controller.view.topAnchor.constraint(equalTo: topAnchor),
                controller.view.bottomAnchor.constraint(equalTo: bottomAnchor),
                controller.view.leadingAnchor.constraint(equalTo: leadingAnchor),
                controller.view.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        } else {
            host?.rootView = AnyView(view)
        }
    }
}

struct MapView: UIViewRepresentable {
    
    // MARK: - Bounds
    /// 철길숲의 남서쪽과 북동쪽 좌표를 기준으로 지도 표시 범위를 계산하는 내부 구조체
    private struct Bounds {
        let southWest: CLLocationCoordinate2D
        let northEast: CLLocationCoordinate2D
        let margin: Double = 1.35
        
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
    
    final class ZoneAnnotation: NSObject, MKAnnotation {
        let coordinate: CLLocationCoordinate2D
        let number: Int
        let color: UIColor
        init(coordinate: CLLocationCoordinate2D, number: Int, color: UIColor) {
            self.coordinate = coordinate
            self.number = number
            self.color = color
        }
    }
    
    /// 경도 이동을 얇게 제한한 '세로 띠' 형태의 CameraBoundary 생성
    private func verticalBandBoundary(bandMeters: Double = 120) -> MKMapView.CameraBoundary {
        let sw = MKMapPoint(bounds.southWest)
        let ne = MKMapPoint(bounds.northEast)

        // 전체 높이는 철길숲 전체 (여유 10%)
        let minY = min(sw.y, ne.y)
        let maxY = max(sw.y, ne.y)
        let height = (maxY - minY) * 1.1
        let originY = minY - (0.05 * (maxY - minY))

        // 중심 경도를 기준으로 bandMeters 폭만큼의 얇은 띠
        let metersPerPoint = MKMetersPerMapPointAtLatitude(bounds.center.latitude)
        let bandPoints = bandMeters / metersPerPoint
        let centerX = MKMapPoint(bounds.center).x
        let originX = centerX - bandPoints / 2.0

        let rect = MKMapRect(x: originX, y: originY, width: bandPoints, height: height)
        return MKMapView.CameraBoundary(mapRect: rect)!
    }
    
    final class ColoredPolyline: MKPolyline {
        var color: UIColor = .white
    }
    
    final class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        let manager = CLLocationManager()
        override init() {
            super.init()
            manager.delegate = self
        }
        
        /// 위치 접근 권한 요청
        func request() {
            manager.requestWhenInUseAuthorization()
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let ann = annotation as? MapView.ZoneAnnotation else { return nil }
            
            let id = "zone.badge"
            let view = (mapView.dequeueReusableAnnotationView(withIdentifier: id) as? HostingAnnotationView)
                ?? HostingAnnotationView(annotation: annotation, reuseIdentifier: id)

            view.annotation = annotation
            view.setSwiftUIView( ZoneBadgeView(number: ann.number, teamColor: Color(ann.color)) )
            view.centerOffset = CGPoint(x: 0, y: -15)
            return view
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let line = overlay as? ColoredPolyline {
                let r = MKPolylineRenderer(overlay: line)
                r.strokeColor = line.color
                r.lineWidth = 16
            
                r.lineCap = .butt
                r.lineJoin = .round
                return r
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
        //        map.showsCompass = false
        
        let config = MKStandardMapConfiguration(elevationStyle: .flat)
        config.pointOfInterestFilter = .excludingAll
        config.showsTraffic = false
        map.preferredConfiguration = config
        
        let region = bounds.region
        map.setRegion(region, animated: true)
        
        let boundary = verticalBandBoundary(bandMeters: 150)
        map.setCameraBoundary(boundary, animated: false)
                
        context.coordinator.request()
        map.showsUserLocation = true
        
        map.delegate = context.coordinator
        
        let badge = ZoneAnnotation(
            coordinate: CLLocationCoordinate2D(latitude: 36.012460, longitude: 129.340923),
            number: 3,
            color: .blue
        )
        map.addAnnotation(badge)
        
        for zone in zones {
            let coords = [zone.zoneStartPoint, zone.zoneEndPoint]
            let polyline = ColoredPolyline(coordinates: coords, count: 2)
            polyline.color = zone.zoneColor
            map.addOverlay(polyline)
        }
        
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
