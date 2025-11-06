//
//  MapView.swift
//  DanDan
//
//  Created by soyeonsoo on 10/26/25.
//

import SwiftUI
import MapKit

// 정류소 버튼을 얹기 위한 MKAnnotation
final class StationAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let zone: Zone
    let statusesForZone: [ZoneConquestStatus]
    
    init(coordinate: CLLocationCoordinate2D, zone: Zone, statusesForZone: [ZoneConquestStatus]) {
        self.coordinate = coordinate
        self.zone = zone
        self.statusesForZone = statusesForZone
    }
}

final class HostingAnnotationView: MKAnnotationView {
    private var host: UIHostingController<AnyView>?
    
    var contentSize: CGSize = CGSize(width: 160, height: 190) {
        didSet {
            self.frame = CGRect(origin: .zero, size: contentSize)
            self.setNeedsLayout()
        }
    }
    
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

// 부분 3D 지도(메인)
struct MapView: UIViewRepresentable {
    var conquestStatuses: [ZoneConquestStatus]
    var teams: [Team]
    
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
    
    private func centroid(of coords: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        guard !coords.isEmpty else { return bounds.center }
        let lat = coords.map { $0.latitude }.reduce(0, +) / Double(coords.count)
        let lon = coords.map { $0.longitude }.reduce(0, +) / Double(coords.count)
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
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
        var isOutline: Bool = false
        var zoneId: Int = 0
    }
    
    // MARK: - Coordinator
    final class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        let manager = CLLocationManager()
        weak var mapView: MKMapView?
        
        var conquestStatuses: [ZoneConquestStatus] = []
        var teams: [Team] = []
        
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
                fromDistance: 500,
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
                fromDistance: 500,
                pitch: 80,
                heading: newHeading.trueHeading
            )
            mapView.setCamera(camera, animated: true)
        }
        
        // Polyline renderer
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let line = overlay as? ColoredPolyline else { return MKOverlayRenderer() }
            
            // 실제 색상 적용
            let renderer = MKPolylineRenderer(overlay: line)
            let color = ZoneColorResolver.leadingColorOrDefault(
                for: line.zoneId,
                in: conquestStatuses,
                teams: teams,
                defaultColor: .primaryGreen // line.color - ui 보여주기용
            )
            renderer.strokeColor = color
            renderer.lineWidth = 24
            renderer.lineCap = .round
            renderer.lineJoin = .round
            return renderer
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let ann = annotation as? StationAnnotation else { return nil }
            
            let id = "station-hosting"
            let view: HostingAnnotationView
            if let reused = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? HostingAnnotationView {
                view = reused
                view.annotation = ann
            } else {
                view = HostingAnnotationView(annotation: ann, reuseIdentifier: id)
            }
            
            // SwiftUI 버튼 주입
            let swiftUIView = ZoneStationButton(
                zone: ann.zone,
                statusesForZone: ann.statusesForZone
            )
            view.setSwiftUIView(swiftUIView)
            
            view.contentSize = CGSize(width: 160, height: 190)
            
            view.centerOffset = CGPoint(x: 10, y: -36)
            view.canShowCallout = false
            
            return view
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
        context.coordinator.conquestStatuses = conquestStatuses
        context.coordinator.teams = teams
        
        for zone in zones {
            let coords = zone.coordinates
            let c = centroid(of: coords)
            let statuses = conquestStatuses.filter { $0.zoneId == zone.zoneId }
            let ann = StationAnnotation(coordinate: c, zone: zone, statusesForZone: statuses)
            map.addAnnotation(ann)
            
            let polyline = ColoredPolyline(coordinates: coords, count: coords.count)
            polyline.zoneId = zone.zoneId
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
