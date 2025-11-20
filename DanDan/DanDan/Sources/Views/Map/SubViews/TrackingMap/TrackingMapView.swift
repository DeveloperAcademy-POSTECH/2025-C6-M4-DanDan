
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
            if let circle = overlay as? MKCircle {
                let r = MKCircleRenderer(overlay: circle)
#if DEBUG
                let title = circle.title ?? ""
                // start: 빨강, end: 파랑. in은 실선, out은 점선
                if title.contains("debug-circle-start") {
                    r.strokeColor = UIColor.systemRed.withAlphaComponent(0.9)
                    r.fillColor = UIColor.systemRed.withAlphaComponent(0.08)
                } else {
                    r.strokeColor = UIColor.systemBlue.withAlphaComponent(0.9)
                    r.fillColor = UIColor.systemBlue.withAlphaComponent(0.08)
                }
                r.lineWidth = 2
                if title.hasSuffix("-out") {
                    r.lineDashPattern = [6, 6]
                }
#endif
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
                view.contentSize = CGSize(width: 80, height: 80)
                view.centerOffset = CGPoint(x: 0, y: -60)
                view.canShowCallout = false
                return view
            }
            guard let ann = annotation as? StationAnnotation else { return nil }
            
            let id = "station-hosting"
            let view: HostingAnnotationView
            if let reused = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? HostingAnnotationView {
                view = reused
                view.annotation = ann
            } else {
                view = HostingAnnotationView(annotation: ann, reuseIdentifier: id)
            }
            
            // 정복 조건(오늘 체크했고, 보상 미수령) 판단 후 뷰 구성
            let isChecked = StatusManager.shared.userStatus.zoneCheckedStatus[ann.zone.zoneId] == true
            let isClaimed = StatusManager.shared.isRewardClaimed(zoneId: ann.zone.zoneId)
            
            let swiftUIView = ZStack {
                // TODO: 제거 예정
                //                ZoneStation(
                //                    zone: ann.zone,
                //                    statusesForZone: ann.statusesForZone,
                //                    zoneTeamScores: viewModel?.zoneTeamScores ?? [:],
                //                    loadZoneTeamScores: { zoneId in
                //                        Task {await self.viewModel!.loadZoneTeamScores(for: zoneId) }
                //                    }
                //                )
                if isChecked && !isClaimed {
                    ConqueredButton(zoneId: ann.zone.zoneId) { ZoneConquerActionHandler.handleConquer(zoneId: $0) }
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
            validRange: 1...15,
            threshold: 120
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
            
            for annotation in uiView.annotations {
                guard let ann = annotation as? StationAnnotation,
                      let view = uiView.view(for: ann) as? HostingAnnotationView else { continue }
                
                let isChecked = StatusManager.shared.userStatus.zoneCheckedStatus[ann.zone.zoneId] == true
                let isClaimed = StatusManager.shared.isRewardClaimed(zoneId: ann.zone.zoneId)
                
                let swiftUIView = ZStack {
                    if isChecked && !isClaimed {
                        ConqueredButton(zoneId: ann.zone.zoneId) { ZoneConquerActionHandler.handleConquer(zoneId: $0) }
                            .offset(y: -120)
                    }
                }
                
                view.setSwiftUIView(swiftUIView)
                view.contentSize = CGSize(width: 160, height: 190)
                view.centerOffset = CGPoint(x: 10, y: -36)
                view.canShowCallout = false
            }
        }
    }
}

struct TrackingMapScreen: View {
    @StateObject private var viewModel = MapScreenViewModel()
    @State private var showZoneList = false
    @State private var onRestoreTracking = false
    @State private var isTracking = true  // 버튼 색상 전환용 상태
    
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
            
            // TODO: 이 버튼 레이아웃 조정을 못 하겠어요.. 현재 머리로는 여기서 padding 말고는 생각이 안 나요 ㅜㅜ 추후 수정..!
            TrackingButton(
                isTracking: $isTracking,
                restoreTracking: {
                    onRestoreTracking = true
                }
            )
            .padding(.top, 204)
            
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
                    
                    TodayMyScore(score: viewModel.userDailyScore)  // 오늘 내 점수
                }
                
                ZStack {
                    if showZoneList {
                        ZoneListPanelView(zoneStatusDetail: viewModel.zoneStatusDetail)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            }
            .padding(.vertical, 58)
            .padding(.horizontal, 20)
            .task {
                await viewModel.loadMapInfo()
                await viewModel.loadZoneStatusDetail()
                viewModel.startDDayTimer(period: period)
            }
            //        .overlay(alignment: .topTrailing) {
            //#if DEBUG
            //            ZoneDebugOverlay()
            //#endif
            //        }
        }
    }
}
