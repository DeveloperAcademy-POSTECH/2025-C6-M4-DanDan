
//  MapView.swift
//  DanDan
//
//  Created by soyeonsoo on 10/26/25.
//

import MapKit
import SwiftUI
import UIKit

// 트래킹 3D 지도
struct TrackingMapView: UIViewRepresentable {
    @ObservedObject var viewModel: MapScreenViewModel
    @Binding var isTracking: Bool // 트래킹 버튼 색 상태
    @Binding var onRestoreTracking: Bool
    @Binding var isDemoMode: Bool
    @Binding var demoCommand: DemoCameraCommand?

    let zoneStatuses: [ZoneStatus]
    var conquestStatuses: [ZoneConquestStatus]
    var teams: [Team]
    var refreshToken: UUID = .init() // 외부 상태 변경 시 강제 update 트리거(렌더러만 갱신)\
    
    // 데모 카메라 제어 명령
    enum DemoCameraCommand {
        case moveForward(distance: CLLocationDistance)
        case moveBackward(distance: CLLocationDistance)
        case rotate(deltaDegrees: CLLocationDirection)
        case followRail(step: CLLocationDistance, forward: Bool)
    }
    
    // MARK: - Constants
    
    /// 실제 철길숲 남서쪽과 북동쪽 경계 좌표, 표시 범위(경계/마진) 정의
    private let bounds = MapBounds(
        southWest: .init(latitude: 35.998605, longitude: 129.316145),
        northEast: .init(latitude: 36.057920, longitude: 129.361197),
        margin: 0.55
    )
    
    /// 중심점 계산 - 정류소 버튼 위치 잡기
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
        var viewModel: MapScreenViewModel?
        
        var zoneStatuses: [ZoneStatus] = []
        var conquestStatuses: [ZoneConquestStatus] = []
        var teams: [Team] = []
        var strokeProvider = ZoneStrokeProvider(zoneStatuses: []) // 구역별 선 색상 계산기
        
        private var lastHeading: CLLocationDirection = 0
        var signsManager: SignsManager?
        var zoneTracker: ZoneTrackerManager?
        var lastChecked: [Int: Bool] = [:]
        var isDemoModeFlag: Bool = false
        
        var isTracking: Binding<Bool>?
        
        override init() {
            super.init()
            manager.delegate = self
        }
        
        // 위치 권한 요청 및 위치/방위 업데이트 시작
        func request() {
            DispatchQueue.main.async {
                self.manager.requestWhenInUseAuthorization() // 위치 정보 접근 권한 요청
                self.manager.allowsBackgroundLocationUpdates = true
                self.manager.showsBackgroundLocationIndicator = true
                self.manager.startUpdatingLocation() // 위치 업데이트 시작
                self.manager.startUpdatingHeading() // 나침반(방향) 업데이트 시작
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }
            let heading = manager.heading?.trueHeading ?? lastHeading
            signsManager?.update(location: location, heading: heading)
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
            // 최신 방위 저장 후 사인 업데이트
            let heading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
            lastHeading = heading
            if let loc = manager.location {
                signsManager?.update(location: loc, heading: heading)
            }
        }
        
        /// 스크롤 후 다시 트래킹 모드로 전환
        func restoreTrackingMode() {
            guard let mapView = mapView else { return }
            mapView.userTrackingMode = .followWithHeading
        }
        
        func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
            let isFollowing =
                (mode == .follow || mode == .followWithHeading)
            
            guard let binding = isTracking else { return }
            
            DispatchQueue.main.async {
                binding.wrappedValue = isFollowing
            }
        }
        
        // 사인 관련 계산/표시는 SignsManager로 이동
        
        // 데모 모드에서 카메라 이동/회전에 맞춰 가짜 위치 업데이트를 SignsManager에 전달
        func applyDemoUpdate(coordinate: CLLocationCoordinate2D, heading: CLLocationDirection) {
            let fakeLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            signsManager?.update(location: fakeLocation, heading: heading)
            
            // 구역 점령 판정(로컬) 업데이트: ZoneTrackerManager 사용
            if let tracker = zoneTracker {
                let before = lastChecked
                tracker.process(location: fakeLocation)
                let current = tracker.userStatus.zoneCheckedStatus
                var newlyCheckedCount = 0
                for (zoneId, isChecked) in current where isChecked == true {
                    if lastChecked[zoneId] != true {
                        StatusManager.shared.setZoneChecked(zoneId: zoneId, checked: true)
                        newlyCheckedCount += 1
                    }
                }
                lastChecked = current
                // 점수/알림은 정복 버튼(ZoneConquerActionHandler.handleConquer)에서만 발생하도록 유지
            }
        }
        
        // MARK: - MKMapViewDelegate
        
        /// 오버레이(폴리라인) 렌더러 - 구역별 색/굵기 등 스타일 지정
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circle = overlay as? MKCircle {
                let r = MKCircleRenderer(overlay: circle)
                let title = circle.title ?? ""
                if title == "demo-circle" {
                    // 데모 위치점: 진한 녹색 점
                    let tint = UIColor(named: "PrimaryGreen") ?? UIColor.systemGreen
                    r.strokeColor = UIColor.white.withAlphaComponent(0.9)
                    r.fillColor = tint.withAlphaComponent(0.9)
                    r.lineWidth = 1.5
                    return r
                }
                // 다른 용도의 디버그 원은 필요 시 기본 스타일로
                r.strokeColor = UIColor.systemBlue.withAlphaComponent(0.7)
                r.fillColor = UIColor.systemBlue.withAlphaComponent(0.15)
                r.lineWidth = 1
                return r
            }
            if let line = overlay as? ColoredPolyline {
                let renderer = MKPolylineRenderer(overlay: line)
                renderer.strokeColor = strokeProvider.stroke(for: line.zoneId, isOutline: line.isOutline)
                renderer.lineWidth = line.isOutline ? 9 : 36
                renderer.lineCap = .round
                renderer.lineJoin = .round
                return renderer
            }
            return MKOverlayRenderer()
        }
        
        /// 어노테이션 뷰 - 정류소 버튼 + 정복 버튼 주입
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let ann = annotation as? SignAnnotation {
                let id = "sign-hosting"
                let view: HostingAnnotationView
                if let reused = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? HostingAnnotationView {
                    view = reused
                    view.annotation = ann
                } else {
                    view = HostingAnnotationView(annotation: ann, reuseIdentifier: id)
                }
                
                let swiftUIView = ZoneSigns(zoneId: ann.destinationZoneId)
                view.setSwiftUIView(swiftUIView)
                view.contentSize = CGSize(width: 120, height: 120)
                view.centerOffset = CGPoint(x: 0, y: -60)
                view.canShowCallout = false
                return view
            }
            // 트래킹 지도에서는 정복 버튼을 지도 어노테이션으로 표시하지 않음
            if annotation is StationAnnotation { return nil }
            return nil
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
    
    // MKMapView 구성(지도 옵션/오버레이/어노테이션)
    private func _createMap(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        
        // MARK: - 테스트용 (자유롭게 움직이기) 주석 처리 부분
        
        //        map.isScrollEnabled = false
        map.isZoomEnabled = false
//        map.isRotateEnabled = false
        map.isPitchEnabled = false
        map.showsCompass = false
        
        // 테스트용 주석 처리 부분 여기까지
        
        let config = MKStandardMapConfiguration(elevationStyle: .realistic)
        config.pointOfInterestFilter = .excludingAll
        config.showsTraffic = false
        map.preferredConfiguration = config
        
        map.delegate = context.coordinator
        context.coordinator.mapView = map
        context.coordinator.isTracking = $isTracking
        context.coordinator.conquestStatuses = conquestStatuses
        context.coordinator.teams = teams
        context.coordinator.zoneStatuses = zoneStatuses
        context.coordinator.strokeProvider = .init(zoneStatuses: zoneStatuses)
        context.coordinator.viewModel = viewModel
        context.coordinator.signsManager = SignsManager(
            mapView: map,
            zones: zones,
            validRange: 1 ... 15,
            threshold: 200
        )
        // 데모용/로컬 점령 판정 트래커
        context.coordinator.zoneTracker = ZoneTrackerManager(zones: zones, userStatus: StatusManager.shared.userStatus)
        context.coordinator.lastChecked = StatusManager.shared.userStatus.zoneCheckedStatus
        context.coordinator.isDemoModeFlag = isDemoMode
        
        // 선과 정류소 버튼 표시
        MapElementInstaller.installOverlays(for: zones, on: map)
        #if DEBUG
        MapElementInstaller.installDebugGateCircles(for: zones, on: map)
        #endif
//        MapElementInstaller.installStations(
//            for: zones,
//            statuses: conquestStatuses,
//            centroidOf: centroid(of:),
//            on: map
//        )
        
        // 카메라/영역
        map.setRegion(bounds.region, animated: true)
        map.setCamera(.init(lookingAtCenter: bounds.center, fromDistance: 500, pitch: 80, heading: 0), animated: false)
        
        map.showsUserLocation = true
        
        // 자동 회전 대신 수동으로 30도 스텝 회전 적용
        map.userTrackingMode = isDemoMode ? .none : .followWithHeading
        map.setCameraZoomRange(
            MKMapView.CameraZoomRange(
                minCenterCoordinateDistance: 100,
                maxCenterCoordinateDistance: 500
            ),
            animated: false
        )
        if isDemoMode {
            context.coordinator.manager.stopUpdatingLocation()
            context.coordinator.manager.stopUpdatingHeading()
        } else {
            context.coordinator.request()
        }
        
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if onRestoreTracking {
            context.coordinator.restoreTrackingMode()
            DispatchQueue.main.async {
                self.onRestoreTracking = false
            }
        }
        
        // 데모 모드 on/off에 따라 트래킹 및 위치 업데이트 토글
        if isDemoMode {
            if uiView.userTrackingMode != .none {
                uiView.userTrackingMode = .none
            }
            context.coordinator.manager.stopUpdatingLocation()
            context.coordinator.manager.stopUpdatingHeading()
            
            // 데모 시작 시 초기 위치를 1구역 시작점으로 설정 + 표시점 배치
            if !hasDemoCircle(on: uiView) {
                let startCoord = zones.first(where: { $0.zoneId == 1 })?.coordinates.first ?? bounds.center
                let cam = uiView.camera
                let updated = MKMapCamera(lookingAtCenter: startCoord,
                                          fromDistance: cam.centerCoordinateDistance,
                                          pitch: cam.pitch,
                                          heading: cam.heading)
                uiView.setCamera(updated, animated: false)
                placeOrMoveDemoCircle(on: uiView, to: startCoord)
                if let coord = uiView.delegate as? Coordinator {
                    coord.applyDemoUpdate(coordinate: startCoord, heading: updated.heading)
                }
            }
        } else {
            if uiView.userTrackingMode != .followWithHeading {
                uiView.userTrackingMode = .followWithHeading
            }
            // 필요 시 재시작
            context.coordinator.request()
            // 데모 모드 종료 시 데모 표시점 제거
            removeDemoCircle(from: uiView)
        }
        
        // 데모 명령 처리
        if isDemoMode, let command = demoCommand {
            apply(command: command, to: uiView)
            DispatchQueue.main.async {
                self.demoCommand = nil
            }
        }
        // 데모 플래그 최신화
        context.coordinator.isDemoModeFlag = isDemoMode
        
        // 변경된 상태 주입
        context.coordinator.zoneStatuses = zoneStatuses
        context.coordinator.conquestStatuses = conquestStatuses
        context.coordinator.teams = teams
        context.coordinator.strokeProvider = .init(zoneStatuses: zoneStatuses)
        
        // 렌더러 색 갱신 + 정류소 데이터 최신화
        DispatchQueue.main.async {
            MapOverlayRefresher.refreshColors(on: uiView, with: context.coordinator.strokeProvider)
        }
    }
    
    // MARK: - Demo Camera Controls

    private func apply(command: DemoCameraCommand, to map: MKMapView) {
        let currentCamera = map.camera
        let currentCenter = map.centerCoordinate
        switch command {
        case .rotate(let deltaDegrees):
            let newHeading = normalizedHeading(currentCamera.heading + deltaDegrees)
            let updated = MKMapCamera(lookingAtCenter: currentCenter,
                                      fromDistance: currentCamera.centerCoordinateDistance,
                                      pitch: currentCamera.pitch,
                                      heading: newHeading)
            map.setCamera(updated, animated: false)
            placeOrMoveDemoCircle(on: map, to: currentCenter)
            if let coord = map.delegate as? Coordinator {
                coord.applyDemoUpdate(coordinate: currentCenter, heading: newHeading)
            }
            
        case .moveForward(let distance):
            // 전진: 카메라 heading 방향으로 정확히 distance(m)
            let coord = move(from: currentCenter, headingDegrees: currentCamera.heading, meters: distance)
            let updated = MKMapCamera(lookingAtCenter: coord,
                                      fromDistance: currentCamera.centerCoordinateDistance,
                                      pitch: currentCamera.pitch,
                                      heading: currentCamera.heading)
            map.setCamera(updated, animated: false)
            placeOrMoveDemoCircle(on: map, to: coord)
            if let coordi = map.delegate as? Coordinator {
                coordi.applyDemoUpdate(coordinate: coord, heading: currentCamera.heading)
            }
            
        case .moveBackward(let distance):
            // 후진: 카메라 heading 반대 방향으로 distance(m)
            let coord = move(from: currentCenter, headingDegrees: normalizedHeading(currentCamera.heading + 180), meters: distance)
            let updated = MKMapCamera(lookingAtCenter: coord,
                                      fromDistance: currentCamera.centerCoordinateDistance,
                                      pitch: currentCamera.pitch,
                                      heading: currentCamera.heading)
            map.setCamera(updated, animated: false)
            placeOrMoveDemoCircle(on: map, to: coord)
            if let coordi = map.delegate as? Coordinator {
                coordi.applyDemoUpdate(coordinate: coord, heading: currentCamera.heading)
            }
            
        case .followRail(let step, let forward):
            if let railCoord = moveAlongRail(from: currentCenter, meters: step, forward: forward) {
                let updated = MKMapCamera(lookingAtCenter: railCoord,
                                          fromDistance: currentCamera.centerCoordinateDistance,
                                          pitch: currentCamera.pitch,
                                          heading: currentCamera.heading)
                map.setCamera(updated, animated: false)
                placeOrMoveDemoCircle(on: map, to: railCoord)
                if let coord = map.delegate as? Coordinator {
                    coord.applyDemoUpdate(coordinate: railCoord, heading: currentCamera.heading)
                }
            }
        }
    }
    
    private func move(from coordinate: CLLocationCoordinate2D, headingDegrees: CLLocationDirection, meters: CLLocationDistance) -> CLLocationCoordinate2D {
        let mapPointsPerMeter = MKMapPointsPerMeterAtLatitude(coordinate.latitude)
        let deltaPoints = meters * mapPointsPerMeter
        let theta = headingDegrees * .pi / 180.0
        let dx = sin(theta) * deltaPoints
        let dy = cos(theta) * deltaPoints
        let start = MKMapPoint(coordinate)
        // MKMapPoint의 Y축은 남쪽(아래)으로 증가하므로, 북쪽(전진)으로 가려면 Y를 감소시켜야 함
        let dest = MKMapPoint(x: start.x + dx, y: start.y - dy)
        return dest.coordinate
    }
    
    private func normalizedHeading(_ degrees: CLLocationDirection) -> CLLocationDirection {
        var d = degrees.truncatingRemainder(dividingBy: 360)
        if d < 0 { d += 360 }
        return d
    }
    
    // MARK: - Rail following helpers

    /// 현재 좌표에서 가장 가까운 폴리라인(구역)의 투영점과 세그먼트를 찾고, 그 선을 따라 meters 만큼 전/후진한 좌표를 계산
    private func moveAlongRail(from coordinate: CLLocationCoordinate2D, meters: CLLocationDistance, forward: Bool) -> CLLocationCoordinate2D? {
        guard let projection = nearestRailProjection(from: coordinate) else { return nil }
        let advanced = advanceAcrossZones(startZoneIndex: projection.zoneIndex,
                                          startSegmentIndex: projection.segmentIndex,
                                          startT: projection.t,
                                          meters: meters,
                                          forward: forward)
        return advanced
    }
    
    private func nearestRailProjection(from coordinate: CLLocationCoordinate2D) -> (zoneIndex: Int, coords: [CLLocationCoordinate2D], segmentIndex: Int, t: Double, projected: CLLocationCoordinate2D)? {
        let p = MKMapPoint(coordinate)
        var best: (zoneIndex: Int, coords: [CLLocationCoordinate2D], segmentIndex: Int, t: Double, projected: CLLocationCoordinate2D)?
        var bestDist = CLLocationDistance.greatestFiniteMagnitude
        
        let oz = orderedZones()
        for (zIdx, zone) in oz.enumerated() {
            let coords = zone.coordinates
            guard coords.count >= 2 else { continue }
            for i in 0 ..< (coords.count - 1) {
                let a = MKMapPoint(coords[i])
                let b = MKMapPoint(coords[i + 1])
                let ab = MKMapPoint(x: b.x - a.x, y: b.y - a.y)
                let ap = MKMapPoint(x: p.x - a.x, y: p.y - a.y)
                let ab2 = ab.x * ab.x + ab.y * ab.y
                let tRaw: Double = ab2 > 0 ? ((ap.x * ab.x + ap.y * ab.y) / ab2) : 0
                let t = max(0, min(1, tRaw))
                let proj = MKMapPoint(x: a.x + t * ab.x, y: a.y + t * ab.y)
                let dist = p.distance(to: proj)
                if dist < bestDist {
                    bestDist = dist
                    best = (zIdx, coords, i, t, proj.coordinate)
                }
            }
        }
        return best
    }
    
    // 여러 구역(폴리라인)을 zoneId 오름차순으로 관통하며 이동
    private func advanceAcrossZones(startZoneIndex: Int, startSegmentIndex: Int, startT: Double, meters: CLLocationDistance, forward: Bool) -> CLLocationCoordinate2D {
        let oz = orderedZones()
        guard !oz.isEmpty else { return bounds.center }
        
        var zIdx = startZoneIndex
        var coords = oz[zIdx].coordinates
        var segIdx = startSegmentIndex
        var t = startT
        var remaining = meters
        
        while remaining > 0 {
            // 세그먼트 범위를 벗어나면 다음/이전 구역으로 전환
            if segIdx < 0 || segIdx >= coords.count - 1 {
                if forward {
                    zIdx += 1
                    guard zIdx < oz.count else { return coords.last ?? bounds.center }
                    coords = oz[zIdx].coordinates
                    segIdx = 0
                    t = 0
                } else {
                    zIdx -= 1
                    guard zIdx >= 0 else { return coords.first ?? bounds.center }
                    coords = oz[zIdx].coordinates
                    segIdx = max(0, coords.count - 2)
                    t = 1
                }
                continue
            }
            
            let a = MKMapPoint(coords[segIdx])
            let b = MKMapPoint(coords[segIdx + 1])
            let ab = MKMapPoint(x: b.x - a.x, y: b.y - a.y)
            let L = a.distance(to: b)
            if L == 0 {
                if forward { segIdx += 1; t = 0 } else { segIdx -= 1; t = 1 }
                continue
            }
            let remainingOnSeg = forward ? (1 - t) * L : t * L
            
            if remaining <= remainingOnSeg {
                let delta = (remaining / L) * (forward ? 1 : -1)
                let newT = max(0, min(1, t + delta))
                let dest = MKMapPoint(x: a.x + newT * ab.x, y: a.y + newT * ab.y)
                return dest.coordinate
            } else {
                remaining -= remainingOnSeg
                if forward { segIdx += 1; t = 0 } else { segIdx -= 1; t = 1 }
            }
        }
        // 남은 거리가 없으면 현재 위치 반환
        let a = MKMapPoint(coords[segIdx])
        let b = MKMapPoint(coords[min(segIdx + 1, coords.count - 1)])
        let ab = MKMapPoint(x: b.x - a.x, y: b.y - a.y)
        let dest = MKMapPoint(x: a.x + t * ab.x, y: a.y + t * ab.y)
        return dest.coordinate
    }
    
    // zoneId 오름차순 정렬
    private func orderedZones() -> [Zone] {
        return zones.sorted { $0.zoneId < $1.zoneId }
    }
    
    private func advanceOnPolyline(coords: [CLLocationCoordinate2D], startSegmentIndex: Int, startT: Double, meters: CLLocationDistance, forward: Bool) -> CLLocationCoordinate2D {
        // 현재 세그먼트 상에서 이동을 시작
        var idx = startSegmentIndex
        var t = startT
        var remaining = meters
        
        func segmentLength(_ i: Int) -> CLLocationDistance {
            let a = MKMapPoint(coords[i])
            let b = MKMapPoint(coords[i + 1])
            return a.distance(to: b)
        }
        
        while remaining > 0 && idx >= 0 && idx < coords.count - 1 {
            let a = MKMapPoint(coords[idx])
            let b = MKMapPoint(coords[idx + 1])
            let ab = MKMapPoint(x: b.x - a.x, y: b.y - a.y)
            let segLen = a.distance(to: b)
            if segLen == 0 {
                // 0 길이 세그먼트는 건너뜀
                if forward { idx += 1; t = 0 } else { idx -= 1; t = 1 }
                continue
            }
            
            // 현재 세그먼트에서 남은 이동 가능 거리
            let remainingOnSeg = forward ? (1 - t) * segLen : t * segLen
            
            if remaining <= remainingOnSeg {
                // 세그먼트 내부에서 종료
                let delta = (remaining / segLen) * (forward ? 1 : -1)
                let newT = t + delta
                let clampedT = max(0, min(1, newT))
                let dest = MKMapPoint(x: a.x + clampedT * ab.x, y: a.y + clampedT * ab.y)
                return dest.coordinate
            } else {
                // 세그먼트 끝까지 이동하고 다음 세그먼트로
                remaining -= remainingOnSeg
                if forward {
                    idx += 1
                    t = 0
                } else {
                    idx -= 1
                    t = 1
                }
            }
        }
        
        // 폴리라인 끝에 도달한 경우 해당 끝점 좌표 반환
        if !coords.isEmpty {
            if forward {
                return coords[min(coords.count - 1, max(0, idx + 1))]
            } else {
                return coords[max(0, min(coords.count - 1, idx))]
            }
        }
        // 이 지점은 일반적으로 도달하지 않지만, 안전하게 기본 좌표 반환
        return coords.first ?? bounds.center
    }
    
    /// 화면 기준(스크린 좌표)으로 지정한 미터만큼 이동한 좌표를 계산
    /// deltaX: 오른쪽(+), deltaY: 아래(+). 전진은 (0, -meters)
    private func moveScreenRelative(map: MKMapView, deltaXMeters: CLLocationDistance, deltaYMeters: CLLocationDistance) -> CLLocationCoordinate2D {
        let centerPoint = CGPoint(x: map.bounds.midX, y: map.bounds.midY)
        
        // 화면 픽셀 1pt당 지도상의 미터 수 계산
        let visible = map.visibleMapRect
        let mapPointsPerPixel = visible.size.width / Double(max(map.bounds.width, 1))
        let mapPointsPerMeter = MKMapPointsPerMeterAtLatitude(map.centerCoordinate.latitude)
        let metersPerPixel = mapPointsPerPixel / mapPointsPerMeter
        
        let dxPixels = CGFloat(deltaXMeters / metersPerPixel)
        let dyPixels = CGFloat(deltaYMeters / metersPerPixel)
        
        let targetPoint = CGPoint(x: centerPoint.x + dxPixels, y: centerPoint.y + dyPixels)
        let targetCoordinate = map.convert(targetPoint, toCoordinateFrom: map)
        return targetCoordinate
    }
    
    // MARK: - Demo marker helpers (MKCircle overlay)

    private func hasDemoCircle(on map: MKMapView) -> Bool {
        return map.overlays.contains { overlay in
            if let circle = overlay as? MKCircle {
                return circle.title == "demo-circle"
            }
            return false
        }
    }
    
    private func removeDemoCircle(from map: MKMapView) {
        let toRemove = map.overlays.compactMap { $0 as? MKCircle }.filter { $0.title == "demo-circle" }
        if !toRemove.isEmpty {
            map.removeOverlays(toRemove)
        }
    }
    
    private func placeOrMoveDemoCircle(on map: MKMapView, to coordinate: CLLocationCoordinate2D) {
        // remove previous
        removeDemoCircle(from: map)
        let circle = MKCircle(center: coordinate, radius: 2.5)
        circle.title = "demo-circle"
        map.addOverlay(circle)
    }
}

struct TrackingMapScreen: View {
    @StateObject private var viewModel = MapScreenViewModel()
    @State private var showZoneList = false
    @State private var onRestoreTracking = false
    @State private var isTracking = true // 버튼 색상 전환용 상태
    @State private var hidePendingCount = false // 정복 버튼 xN 텍스트를 숨기기 위한 플래그
    @ObservedObject private var status = StatusManager.shared
    @State private var isDemoMode = false
    @State private var demoCommand: TrackingMapView.DemoCameraCommand? = nil
    
    let conquestStatuses: [ZoneConquestStatus]
    let teams: [Team]
    let userStatus: UserStatus
    let period: ConquestPeriod
    let refreshToken: UUID
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .top) {
            // 3D 부분 지도
            TrackingMapView(
                viewModel: viewModel,
                isTracking: $isTracking,
                onRestoreTracking: $onRestoreTracking,
                isDemoMode: $isDemoMode,
                demoCommand: $demoCommand,
                zoneStatuses: viewModel.zoneStatuses,
                conquestStatuses: conquestStatuses,
                teams: teams,
                refreshToken: refreshToken
            )
            .ignoresSafeArea()
            
            // TODO: 이 버튼 레이아웃 조정을 못 하겠어요.. 현재 머리로는 여기서 padding 말고는 생각이 안 나요 ㅜㅜ 추후 수정..!
            TrackingButton(
                isTracking: $isTracking,
                restoreTracking: {
                    onRestoreTracking = true
                }
            )
            .padding(.top, 204)
            
            // 데모 모드 토글 버튼
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Button {
                        isDemoMode.toggle()
                        if isDemoMode {
                            // 데모 모드 진입 시 트래킹 버튼 off
                            isTracking = false
                        }
                    } label: {
                        Text(isDemoMode ? "조이스틱 ON" : "조이스틱 OFF")
                            .font(.PR.caption5)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(isDemoMode ? Color.primaryGreen : Color.gray3)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                }
                Spacer()
            }
            .padding(.top, 250)
            
            VStack(alignment: .leading) {
                HStack(spacing: 2) {
                    if viewModel.teams.count >= 2 {
                        ScoreBoard(
                            leftTeamName: viewModel.teams[1].teamName,
                            rightTeamName: viewModel.teams[0].teamName,
                            leftTeamScore: viewModel.teams[1].conqueredZones,
                            rightTeamScore: viewModel.teams[0].conqueredZones,
                            ddayText: viewModel.ddayText
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                showZoneList.toggle()
                            }
                        }
                    } else {
                        // 로딩 중일 때는 기본값 표시
                        ScoreBoard(
                            leftTeamName: "—",
                            rightTeamName: "—",
                            leftTeamScore: 0,
                            rightTeamScore: 0,
                            ddayText: viewModel.ddayText
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                showZoneList.toggle()
                            }
                        }
                    }
                    
                    Spacer()
                    
                    TodayMyScore(score: viewModel.userDailyScore) // 오늘 내 점수
                }
                    
                if showZoneList {
                    ZoneListPanelView(zoneStatusDetail: viewModel.zoneStatusDetail)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(.vertical, 58)
            .padding(.horizontal, 20)
            
            // ScoreBoard 아래 왼쪽: 정복 버튼(집계)
            let pendingZoneIds: [Int] = zones
                .map(\.zoneId)
                .filter { id in
                    let checked = status.userStatus.zoneCheckedStatus[id] == true
                    let claimed = StatusManager.shared.isRewardClaimed(zoneId: id)
                    return checked && !claimed
                }
            
            if !pendingZoneIds.isEmpty {
                HStack(spacing: 0) {
                    let content = HStack(spacing: 0) {
                        ConqueredButton(zoneId: pendingZoneIds.first ?? 0) { _ in
                            hidePendingCount = true // 버튼 탭 시 곧바로 xN 텍스트 숨김
                            ZoneConquerActionHandler.handleConquer(zoneIds: pendingZoneIds)
                        }
                        if pendingZoneIds.count >= 2 && !hidePendingCount {
                            Text("x\(pendingZoneIds.count)")
                                .font(.PR.title2)
                                .foregroundColor(.steelBlack)
                        }
                    }
                    content
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 150)
            } else {
                // pendingZoneIds가 비워지면 다음 사이클을 위해 xN 표시 플래그를 초기화
                EmptyView()
                    .onAppear {
                        hidePendingCount = false
                    }
            }

            // 조이스틱 오버레이
            if isDemoMode {
                JoystickOverlay(
                    onMoveForward: {
                        demoCommand = nil
                        DispatchQueue.main.async { demoCommand = .moveForward(distance: 20) }
                    },
                    onMoveBackward: {
                        demoCommand = nil
                        DispatchQueue.main.async { demoCommand = .moveBackward(distance: 20) }
                    },
                    onRotateLeft: {
                        demoCommand = nil
                        DispatchQueue.main.async { demoCommand = .rotate(deltaDegrees: -15) }
                    },
                    onRotateRight: {
                        demoCommand = nil
                        DispatchQueue.main.async { demoCommand = .rotate(deltaDegrees: 15) }
                    },
                    onForwardRepeat: {
                        demoCommand = nil
                        DispatchQueue.main.async { demoCommand = .followRail(step: 5, forward: true) }
                    },
                    onBackwardRepeat: {
                        demoCommand = nil
                        DispatchQueue.main.async { demoCommand = .followRail(step: 5, forward: false) }
                    }
                )
                .padding(.trailing, 20)
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
        }
        .task {
            await viewModel.loadZoneStatusDetail()
            await viewModel.loadMapInfo(updateScore: true)
            viewModel.startDDayTimer(period: period)
        }
        .onReceive(NotificationCenter.default.publisher(for: ZoneConquerActionHandler.didUpdateScoreNotification)) { _ in
            if isDemoMode {
                // 데모 모드에서는 서버를 호출하지 않고 로컬 상태를 반영
                viewModel.userDailyScore = StatusManager.shared.userStatus.userDailyScore
            } else {
                Task { @MainActor in
                    await viewModel.loadMapInfo(updateScore: true)
                }
            }
        }
        //        .overlay(alignment: .topTrailing) {
        // #if DEBUG
        //            ZoneDebugOverlay()
        // #endif
        //        }
    }
}

// MARK: - Joystick Overlay

private struct JoystickOverlay: View {
    let onMoveForward: () -> Void
    let onMoveBackward: () -> Void
    let onRotateLeft: () -> Void
    let onRotateRight: () -> Void
    let onForwardRepeat: () -> Void
    let onBackwardRepeat: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            RepeatPressButton(systemImageName: "arrow.up.circle.fill", onTap: onMoveForward, onRepeat: onForwardRepeat)
//            HStack(spacing: 8) {
//                Button(action: onRotateLeft) {
//                    Image(systemName: "arrow.counterclockwise.circle.fill")
//                        .font(.system(size: 40))
//                        .foregroundColor(.primaryGreen)
//                }
//                Button(action: onRotateRight) {
//                    Image(systemName: "arrow.clockwise.circle.fill")
//                        .font(.system(size: 40))
//                        .foregroundColor(.primaryGreen)
//                }
//            }
            RepeatPressButton(systemImageName: "arrow.down.circle.fill", onTap: onMoveBackward, onRepeat: onBackwardRepeat)
        }
        .padding(10)
        .background(
            VisualEffectBlur()
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        )
        .padding(.bottom, 30)
    }
}

// 길게 누르는 동안 주기적으로 onRepeat를 호출하는 버튼
private struct RepeatPressButton: View {
    let systemImageName: String
    let onTap: () -> Void
    let onRepeat: () -> Void
    
    @State private var isPressing: Bool = false
    @State private var timer: Timer?
    
    var body: some View {
        Image(systemName: systemImageName)
            .font(.system(size: 40))
            .foregroundColor(.primaryGreen)
            .onLongPressGesture(minimumDuration: 0.15, pressing: { pressing in
                if pressing {
                    isPressing = true
                    startRepeating()
                } else {
                    isPressing = false
                    stopRepeating()
                }
            }, perform: {})
    }
    
    private func startRepeating() {
        stopRepeating()
        // 약 8Hz (0.125초 간격)로 반복
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            onRepeat()
        }
    }
    
    private func stopRepeating() {
        timer?.invalidate()
        timer = nil
    }
}

// 간단한 블러 백그라운드 (디자인시스템 내 이미 있을 수 있어 경량 구현)
private struct VisualEffectBlur: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
