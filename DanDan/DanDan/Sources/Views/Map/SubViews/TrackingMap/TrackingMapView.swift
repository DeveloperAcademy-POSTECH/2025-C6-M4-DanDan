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
    let zoneStatuses: [ZoneStatus]
    var conquestStatuses: [ZoneConquestStatus]
    var teams: [Team]
    var refreshToken: UUID = UUID() // 외부 상태 변경 시 강제 update 트리거(렌더러만 갱신)
    
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
        
        override init() {
            super.init()
            manager.delegate = self
        }
        
        // 위치 권한 요청 및 위치/방위 업데이트 시작
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
        
        // MARK: - MKMapViewDelegate
        /// 오버레이(폴리라인) 렌더러 - 구역별 색/굵기 등 스타일 지정
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let line = overlay as? ColoredPolyline else {
                return MKOverlayRenderer()
            }
            let renderer = MKPolylineRenderer(overlay: line)
            renderer.strokeColor = strokeProvider.stroke(for: line.zoneId, isOutline: line.isOutline)
            renderer.lineWidth = line.isOutline ? 9 : 36
            renderer.lineCap = .round
            renderer.lineJoin = .round
            return renderer
        }
        
        /// 어노테이션 뷰 - 정류소 버튼 + 정복 버튼 주입
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
            
            // 정복 조건(오늘 체크했고, 보상 미수령) 판단 후 뷰 구성
            let isChecked = StatusManager.shared.userStatus.zoneCheckedStatus[ann.zone.zoneId] == true
            let isClaimed = StatusManager.shared.isRewardClaimed(zoneId: ann.zone.zoneId)
            
            let swiftUIView = ZStack {
                ZoneStation(
                    viewModel: viewModel ?? MapScreenViewModel(),
                    zone: ann.zone,
                    statusesForZone: ann.statusesForZone
                )
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
        context.coordinator.viewModel = viewModel

        
        // 선과 정류소 버튼 표시
        MapElementInstaller.installOverlays(for: zones, on: map)
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
            MapOverlayRefresher.refreshColors(on: uiView, with: context.coordinator.strokeProvider)
        }
    }
}

struct TrackingMapScreen: View {
    @StateObject private var viewModel = MapScreenViewModel()

    let conquestStatuses: [ZoneConquestStatus]
    let teams: [Team]
    let userStatus: UserStatus
    let period: ConquestPeriod
    let refreshToken: UUID

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .topLeading) {
            // 3D 부분 지도
                TrackingMapView(
                    viewModel: viewModel,
                    zoneStatuses: viewModel.zoneStatuses,
                    conquestStatuses: conquestStatuses,
                    teams: teams,
                    refreshToken: refreshToken
                )
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    if viewModel.teams.count >= 2 {
                        ScoreBoard(
                            leftTeamName: viewModel.teams[1].teamName,
                            rightTeamName: viewModel.teams[0].teamName,
                            leftTeamScore: viewModel.teams[1].conqueredZones,
                            rightTeamScore: viewModel.teams[0].conqueredZones
                        )
                    } else {
                        // 로딩 중일 때는 기본값 표시
                        ScoreBoard(
                            leftTeamName: "—",
                            rightTeamName: "—",
                            leftTeamScore: 0,
                            rightTeamScore: 0
                        )
                    }

                    TodayMyScore(score: viewModel.userDailyScore)  // 오늘 내 점수
                }

                if !viewModel.startDate.isEmpty {
                    DDayView(
                        dday: ConquestPeriod.from(
                            endDateString: viewModel.endDate
                        ),
                        period: period
                    )
                    .padding(.leading, 4)
                }
            }
            .padding(.top, 60)
            .padding(.leading, 14)
        }
        .task {
            await viewModel.loadMapInfo()
        }
    }
}
