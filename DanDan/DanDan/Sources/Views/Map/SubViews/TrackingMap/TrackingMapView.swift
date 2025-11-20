//
//  MapView.swift
//  DanDan
//
//  Created by soyeonsoo on 10/26/25.
//

import MapKit
import SwiftUI

// 트래킹 3D 지도
struct TrackingMapView: UIViewRepresentable {
    @ObservedObject var viewModel: MapScreenViewModel
    @Binding var isTracking: Bool // 트래킹 버튼 색 상태
    @Binding var onRestoreTracking: Bool

    let zoneStatuses: [ZoneStatus]
    var conquestStatuses: [ZoneConquestStatus]
    var teams: [Team]
    var refreshToken: UUID = .init() // 외부 상태 변경 시 강제 update 트리거(렌더러만 갱신)\
    
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
        
        // MARK: - MKMapViewDelegate
        
        /// 오버레이(폴리라인) 렌더러 - 구역별 색/굵기 등 스타일 지정
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//            if let circle = overlay as? MKCircle {
//                let r = MKCircleRenderer(overlay: circle)
            // #if DEBUG
//                let title = circle.title ?? ""
//                // start: 빨강, end: 파랑. in은 실선, out은 점선
//                if title.contains("debug-circle-start") {
//                    r.strokeColor = UIColor.systemRed.withAlphaComponent(0.9)
//                    r.fillColor = UIColor.systemRed.withAlphaComponent(0.08)
//                } else {
//                    r.strokeColor = UIColor.systemBlue.withAlphaComponent(0.9)
//                    r.fillColor = UIColor.systemBlue.withAlphaComponent(0.08)
//                }
//                r.lineWidth = 2
//                if title.hasSuffix("-out") {
//                    r.lineDashPattern = [6, 6]
//                }
            // #endif
//                return r
//            }
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
        
        // 선과 정류소 버튼 표시
        MapElementInstaller.installOverlays(for: zones, on: map)
        #if DEBUG
        MapElementInstaller.installDebugGateCircles(for: zones, on: map)
        #endif
        MapElementInstaller.installStations(
            for: zones,
            statuses: conquestStatuses,
            centroidOf: centroid(of:),
            on: map
        )
        
        // 카메라/영역
        map.setRegion(bounds.region, animated: true)
        map.setCamera(.init(lookingAtCenter: bounds.center, fromDistance: 500, pitch: 80, heading: 0), animated: false)
        
        map.showsUserLocation = true
        
        map.userTrackingMode = .followWithHeading
        map.setCameraZoomRange(
            MKMapView.CameraZoomRange(
                minCenterCoordinateDistance: 100,
                maxCenterCoordinateDistance: 500
            ),
            animated: false
        )
        context.coordinator.request()
        
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if onRestoreTracking {
            context.coordinator.restoreTrackingMode()
            DispatchQueue.main.async {
                self.onRestoreTracking = false
            }
        }
        
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
}

struct TrackingMapScreen: View {
    @StateObject private var viewModel = MapScreenViewModel()
    @State private var onRestoreTracking = false
    @State private var isTracking = true // 버튼 색상 전환용 상태
    @State private var hidePendingCount = false   // 정복 버튼 xN 텍스트를 숨기기 위한 플래그
    @ObservedObject private var status = StatusManager.shared
    
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
                zoneStatuses: viewModel.zoneStatuses,
                conquestStatuses: conquestStatuses,
                teams: teams,
                refreshToken: refreshToken
            )
            .ignoresSafeArea()
            
            VStack {
                HStack(spacing: 2) {
                    if viewModel.teams.count >= 2 {
                        ScoreBoard(
                            leftTeamName: viewModel.teams[1].teamName,
                            rightTeamName: viewModel.teams[0].teamName,
                            leftTeamScore: viewModel.teams[1].conqueredZones,
                            rightTeamScore: viewModel.teams[0].conqueredZones,
                            ddayText: viewModel.ddayText
                        )
                    } else {
                        // 로딩 중일 때는 기본값 표시
                        ScoreBoard(
                            leftTeamName: "—",
                            rightTeamName: "—",
                            leftTeamScore: 0,
                            rightTeamScore: 0,
                            ddayText: viewModel.ddayText
                        )
                    }
                    
                    Spacer()
                    
                    TodayMyScore(score: viewModel.userDailyScore) // 오늘 내 점수
                }
                .padding(.vertical, 58)
                .padding(.horizontal, 20)
                 
                // 트래킹 버튼(오른쪽 상단 고정)
                TrackingButton(
                    isTracking: $isTracking,
                    restoreTracking: {
                        onRestoreTracking = true
                    }
                )
            }
            
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
                            hidePendingCount = true    // 버튼 탭 시 곧바로 xN 텍스트 숨김
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
            }
            else {
                // pendingZoneIds가 비워지면 다음 사이클을 위해 xN 표시 플래그를 초기화
                EmptyView()
                    .onAppear {
                        hidePendingCount = false
                    }
            }

        }
        .task {
            await viewModel.loadMapInfo()
            viewModel.startDDayTimer(period: period)
        }
        // 점수/상태 갱신 알림 수신하여 상단 점수 동기화
        .onReceive(NotificationCenter.default.publisher(for: ZoneConquerActionHandler.didUpdateScoreNotification)) { _ in
            viewModel.userDailyScore = StatusManager.shared.userStatus.userDailyScore
        }
        //        .overlay(alignment: .topTrailing) {
        //#if DEBUG
        //            ZoneDebugOverlay()
        //#endif
        //        }
    }
}
