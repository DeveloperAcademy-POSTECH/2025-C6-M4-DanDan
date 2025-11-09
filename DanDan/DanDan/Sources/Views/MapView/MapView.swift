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
    let zoneStatuses: [ZoneStatus]
    var conquestStatuses: [ZoneConquestStatus]
    var teams: [Team]
    // 외부 상태 변경에 따른 갱신 트리거용 토큰 (뷰 재생성 없이 update만 유도)
    var refreshToken: UUID = UUID()
    
    // MARK: - Constants
    /// 실제 철길숲 남서쪽과 북동쪽 경계 좌표
    private let bounds = MapBounds(
        southWest: .init(latitude: 35.998605, longitude: 129.316145),
        northEast: .init(latitude: 36.057920, longitude: 129.361197),
        margin: 0.55
    )
    
    // 중심점 계산
    private func centroid(of coords: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        guard !coords.isEmpty else { return bounds.center }
        let lat = coords.map(\.latitude).reduce(0, +) / Double(coords.count)
        let lon = coords.map(\.longitude).reduce(0, +) / Double(coords.count)
        return .init(latitude: lat, longitude: lon)
    }
    
    // MARK: - Coordinator
    final class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        let manager = CLLocationManager()
        weak var mapView: MKMapView?
        
        var zoneStatuses: [ZoneStatus] = []  
        var conquestStatuses: [ZoneConquestStatus] = []
        var teams: [Team] = []
        var strokeProvider = ZoneStrokeProvider(zoneStatuses: [])
        
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
        
        // MARK: - 테스트용 (자유롭게 움직이기) 주석 처리 부분
        
        // 사용자의 위치에 따라 카메라 중심 이동
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let mapView = mapView,
                  let location = locations.last else { return }
            DispatchQueue.main.async {
                let camera = MKMapCamera(
                    lookingAtCenter: location.coordinate,
                    fromDistance: 500,
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
                    fromDistance: 500,
                    pitch: 80,
                    heading: newHeading.trueHeading
                )
                mapView.setCamera(camera, animated: true)
            }
        }
        
        // 테스트용 주석 처리 부분 여기까지
        
        // 오버레이(선) 생성
        func installOverlays(for zones: [Zone], on map: MKMapView) {
            for z in zones {
                let coords = z.coordinates
                
                // 1) 기본 폴리라인(팀 색칠용)
                let base = ColoredPolyline(coordinates: coords, count: coords.count)
                base.zoneId = z.zoneId
                map.addOverlay(base, level: .aboveRoads)
                
                // 2) 외곽선 폴리라인(오늘 지나간 구역 하이라이트용)
                let outline = ColoredPolyline(coordinates: coords, count: coords.count)
                outline.zoneId = z.zoneId
                outline.isOutline = true
                map.addOverlay(outline, level: .aboveRoads)
            }
        }
        
        // 어노테이션(정류소) 생성
        func installStations(
            for zones: [Zone],
            statuses: [ZoneConquestStatus],
            centroidOf: ([CLLocationCoordinate2D]) -> CLLocationCoordinate2D,
            on map: MKMapView)
        {
            for z in zones {
                let c = centroidOf(z.coordinates)
                let zoneStatuses = statuses.filter { $0.zoneId == z.zoneId }
                let ann = StationAnnotation(coordinate: c, zone: z, statusesForZone: zoneStatuses)
                map.addAnnotation(ann)
            }
        }
        
        // MARK: - MKMapViewDelegate
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let line = overlay as? ColoredPolyline else { return MKOverlayRenderer() }
            let r = MKPolylineRenderer(overlay: line)
            r.strokeColor = strokeProvider.stroke(for: line.zoneId, isOutline: line.isOutline)
            r.lineWidth = line.isOutline ? 9 : 36
            r.lineCap = .round
            r.lineJoin = .round
            return r
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
            
            // SwiftUI 정류소 버튼 + 정복 버튼 주입
            let isChecked = StatusManager.shared.userStatus.zoneCheckedStatus[ann.zone.zoneId] == true
            let isClaimed = StatusManager.shared.isRewardClaimed(zoneId: ann.zone.zoneId)
            
            let swiftUIView = ZStack {
                ZoneStationButton(zone: ann.zone, statusesForZone: ann.statusesForZone)
                if isChecked && !isClaimed {
                    ConqueredButton(zoneId: ann.zone.zoneId) { id in
                        ZoneCheckedService.shared.postChecked(zoneId: id) { ok in
                            guard ok else { print("🚨 postChecked failed: \(id)"); return }
                            ZoneCheckedService.shared.acquireScore(zoneId: id) { ok2 in
                                if ok2 {
                                    StatusManager.shared.incrementDailyScore()
                                    StatusManager.shared.setRewardClaimed(zoneId: id, claimed: true)
                                } else {
                                    print("🚨 acquireScore failed: \(id)")
                                }
                            }
                        }
                    }
                    .offset(y: -120)
                }
            }
            view.setSwiftUIView(swiftUIView)
            view.contentSize = CGSize(width: 160, height: 190)
            view.centerOffset = CGPoint(x: 10, y: -36)
            view.canShowCallout = false
            return view
        }
    }
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    func makeUIView(context: Context) -> MKMapView {
        if !Thread.isMainThread {
            var created: MKMapView!
            DispatchQueue.main.sync { created = self._createMap(context: context) }
            return created
        }
        return _createMap(context: context)
    }

    private func _createMap(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        
        // MARK: - 테스트용 (자유롭게 움직이기) 주석 처리 부분

        map.isScrollEnabled = false
        map.isZoomEnabled = false
        map.isRotateEnabled = false
        map.isPitchEnabled = false
        map.showsCompass = false
        
        // 테스트용 주석 처리 부분 여기까지
        
        let config = MKStandardMapConfiguration(elevationStyle: .realistic)
        config.pointOfInterestFilter = .excludingAll
        config.showsTraffic = false
        map.preferredConfiguration = config
        
        map.delegate = context.coordinator
        context.coordinator.mapView = map
        context.coordinator.conquestStatuses = conquestStatuses
        context.coordinator.teams = teams
        context.coordinator.zoneStatuses = zoneStatuses
        context.coordinator.strokeProvider = .init(zoneStatuses: zoneStatuses)
        
        // 오버레이/정류소 설치
        context.coordinator.installOverlays(for: zones, on: map)
        context.coordinator.installStations(for: zones, statuses: conquestStatuses, centroidOf: centroid(of:), on: map)
        
        // 카메라/영역
        map.setRegion(bounds.region, animated: true)
        map.setCamera(.init(lookingAtCenter: bounds.center, fromDistance: 500, pitch: 80, heading: 0), animated: false)
        
        map.showsUserLocation = true
        context.coordinator.request()
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 변경된 상태 주입
        context.coordinator.zoneStatuses = zoneStatuses
        context.coordinator.conquestStatuses = conquestStatuses
        context.coordinator.teams = teams
        context.coordinator.strokeProvider = .init(zoneStatuses: zoneStatuses)
        
        // 렌더러만 색 갱신
        DispatchQueue.main.async {
            for overlay in uiView.overlays {
                guard let line = overlay as? ColoredPolyline,
                      let renderer = uiView.renderer(for: overlay) as? MKPolylineRenderer else { continue }
                renderer.strokeColor = context.coordinator.strokeProvider.stroke(for: line.zoneId, isOutline: line.isOutline)
                renderer.setNeedsDisplay()
            }
        }
    }
}
