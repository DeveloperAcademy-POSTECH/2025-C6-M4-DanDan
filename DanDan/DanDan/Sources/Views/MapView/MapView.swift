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
    
    var conquestStatuses: [ZoneConquestStatus]
    var teams: [Team]
    // 외부 상태 변경에 따른 갱신 트리거용 토큰 (뷰 재생성 없이 update만 유도)
    var refreshToken: UUID = UUID()
    
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
            DispatchQueue.main.async {
                self.manager.requestWhenInUseAuthorization() // 위치 정보 접근 권한 요청
                self.manager.startUpdatingLocation() // 위치 업데이트 시작
                self.manager.startUpdatingHeading() // 나침반(방향) 업데이트 시작
            }
        }
        
        // 사용자의 위치에 따라 카메라 중심 이동
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let mapView = mapView,
                  let location = locations.last else { return }
            DispatchQueue.main.async {
                let camera = MKMapCamera(
                    lookingAtCenter: location.coordinate,
                    fromDistance: 800,
                    pitch: 80,
                    heading: mapView.camera.heading
                )
                mapView.setCamera(camera, animated: true)
            }
        }
        
        // 유저의 방향(heading) 변경에 따라 지도 회전
        func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
            guard let mapView = mapView else { return }
            DispatchQueue.main.async {
                let currentCenter = mapView.camera.centerCoordinate
                let camera = MKMapCamera(
                    lookingAtCenter: currentCenter,
                    fromDistance: 800,
                    pitch: 80,
                    heading: newHeading.trueHeading
                )
                mapView.setCamera(camera, animated: true)
            }
        }
        
        // Polyline renderer
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let line = overlay as? ColoredPolyline else { return MKOverlayRenderer() }
            
            // 실제 색상 적용
            let renderer = MKPolylineRenderer(overlay: line)
            if line.isOutline {
                let checked = StatusManager.shared.userStatus.zoneCheckedStatus[line.zoneId] == true
                renderer.strokeColor = checked ? UIColor.white.withAlphaComponent(0.85) : UIColor.clear
                renderer.lineWidth = 8
                renderer.lineCap = .round
                renderer.lineJoin = .round
                return renderer
            } else {
                let color = ZoneColorResolver.leadingColorOrDefault(
                    for: line.zoneId,
                    in: conquestStatuses,
                    teams: teams,
                    defaultColor: .primaryGreen // line.color - ui 보여주기 용
                )
                renderer.strokeColor = color
                renderer.lineWidth = 24
                renderer.lineCap = .round
                renderer.lineJoin = .round
                return renderer
            }
        }
    }
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    func makeUIView(context: Context) -> MKMapView {
        if !Thread.isMainThread {
            var created: MKMapView!
            DispatchQueue.main.sync {
                created = self._createMap(context: context)
            }
            return created
        }
        return _createMap(context: context)
    }

    private func _createMap(context: Context) -> MKMapView {
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
            let base = ColoredPolyline(coordinates: coords, count: coords.count)
            base.zoneId = zone.zoneId
            base.color = zone.zoneColor
            map.addOverlay(base, level: .aboveRoads)

            // 하이라이트(오늘 체크한 구역) 오버레이
            let outline = ColoredPolyline(coordinates: coords, count: coords.count)
            outline.zoneId = zone.zoneId
            outline.isOutline = true
            map.addOverlay(outline, level: .aboveRoads)
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
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 데이터 변경 시 렌더러 컬러만 업데이트 (오버레이는 제거/재추가하지 않음)
        context.coordinator.conquestStatuses = conquestStatuses
        context.coordinator.teams = teams
        DispatchQueue.main.async {
            for overlay in uiView.overlays {
                guard let line = overlay as? ColoredPolyline,
                      let renderer = uiView.renderer(for: overlay) as? MKPolylineRenderer else { continue }
                if line.isOutline {
                    let checked = StatusManager.shared.userStatus.zoneCheckedStatus[line.zoneId] == true
                    renderer.strokeColor = checked ? UIColor.white.withAlphaComponent(0.85) : UIColor.clear
                } else {
                    let color = ZoneColorResolver.leadingColorOrDefault(
                        for: line.zoneId,
                        in: conquestStatuses,
                        teams: teams,
                        defaultColor: .primaryGreen
                    )
                    renderer.strokeColor = color
                }
                renderer.setNeedsDisplay()
            }
        }
    }
}
