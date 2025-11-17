//
//  FullMapView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/1/25.
//

import MapKit
import SwiftUI

// Canvas host annotation for overlaying station/conquer buttons in view space
final class CanvasAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    init(coordinate: CLLocationCoordinate2D) { self.coordinate = coordinate }
}

// 전체 2D 지도
struct FullMapView: UIViewRepresentable {
    @ObservedObject var viewModel: MapScreenViewModel
    let zoneStatuses: [ZoneStatus]
    enum Mode { case overall, personal }
    let conquestStatuses: [ZoneConquestStatus]
    let teams: [Team]
    var mode: Mode = .overall
    // 외부 상태 변경에 따른 갱신 트리거용 토큰
    var refreshToken: UUID = .init()
    
    // MARK: - Constants
    /// 실제 철길숲 남서쪽과 북동쪽 경계 좌표
    private let bounds = MapBounds(
        southWest: .init(latitude: 35.998605, longitude: 129.316145),
        northEast: .init(latitude: 36.057920, longitude: 129.361197),
        margin: 1.35
    )
    
    /// 중심점 계산 - 정류소 버튼 위치 잡기
    private func centroid(of coords: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        guard !coords.isEmpty else { return bounds.center }
        let lat = coords.map(\.latitude).reduce(0, +) / Double(coords.count)
        let lon = coords.map(\.longitude).reduce(0, +) / Double(coords.count)
        return .init(latitude: lat, longitude: lon)
    }
    
    final class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        let manager = CLLocationManager()
        weak var mapView: MKMapView?
        var viewModel: MapScreenViewModel?
        
        var zoneStatuses: [ZoneStatus] = []
        var conquestStatuses: [ZoneConquestStatus] = []
        var teams: [Team] = []
        var strokeProvider = ZoneStrokeProvider(zoneStatuses: []) // 구역별 선 색상 계산기
        var mode: Mode = .overall

        var parent: FullMapView

        // Holds all stations with their view-space positions
        struct PositionedStation: Identifiable {
            let id: Int // zoneId
            let zone: Zone
            let statusesForZone: [ZoneConquestStatus]
            let point: CGPoint
            let needsClaim: Bool
        }
        var positioned: [PositionedStation] = []

        init(parent: FullMapView) {
            self.parent = parent
            super.init()
            manager.delegate = self
        }
        
        func request() {
            manager.requestWhenInUseAuthorization()
        }
        
        func updatePositions(for mapView: MKMapView) {
            // Convert each zone centroid to view-space point
            positioned = zones.map { z in
                let coord = parent.centroid(of: z.coordinates)
                let pt = mapView.convert(coord, toPointTo: mapView)
                let isChecked = StatusManager.shared.userStatus.zoneCheckedStatus[z.zoneId] == true
                let isClaimed = StatusManager.shared.isRewardClaimed(zoneId: z.zoneId)
                return PositionedStation(
                    id: z.zoneId,
                    zone: z,
                    statusesForZone: conquestStatuses.filter { $0.zoneId == z.zoneId },
                    point: pt,
                    needsClaim: isChecked && !isClaimed
                )
            }
        }
        
        // MARK: - MKMapViewDelegate
        /// 오버레이(폴리라인/디버그 원) 렌더러 - 구역별 색/굵기 등 스타일 지정
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circle = overlay as? MKCircle {
                let r = MKCircleRenderer(overlay: circle)
                #if DEBUG
                let title = circle.title ?? ""
                if title.contains("debug-circle-start") {
                    r.strokeColor = UIColor.systemRed.withAlphaComponent(0.9)
                    r.fillColor = UIColor.systemRed.withAlphaComponent(0.06)
                } else {
                    r.strokeColor = UIColor.systemBlue.withAlphaComponent(0.9)
                    r.fillColor = UIColor.systemBlue.withAlphaComponent(0.06)
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
                
                let stroke: UIColor
                switch mode {
                case .overall:
                    stroke = ZoneColorResolver.leadingColorOrDefault(
                        for: line.zoneId,
                        zoneStatuses: zoneStatuses,
                        defaultColor: .primaryGreen
                    )
                case .personal:
                    let checked =
                    StatusManager.shared.userStatus.zoneCheckedStatus[
                        line.zoneId
                    ] == true
                    if checked {
                        let teamName = StatusManager.shared.userStatus.userTeam
                        let personalColor: UIColor
                        switch teamName {
                        case "Blue":
                            personalColor = .subA
                        case "Yellow":
                            personalColor = .subB
                        default:
                            personalColor = .primaryGreen
                        }
                        stroke = personalColor
                    } else {
                        stroke = UIColor.primaryGreen
                    }
                }
                renderer.strokeColor = stroke
                renderer.lineWidth = 16
                renderer.lineCap = .round
                renderer.lineJoin = .round
                return renderer
            }
            return MKOverlayRenderer()
        }
        

        // MARK: - Drag handling
        /// 드래그 종료 지점 좌표를 뷰모델에 전달하여 최근접 구역 선택
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let mapView else { return }
            let location = gesture.location(in: mapView)
            switch gesture.state {
            case .ended:
                let coord = mapView.convert(location, toCoordinateFrom: mapView)
                viewModel?.pickNearestZone(to: coord)
            default:
                break
            }
        }
        
        // MARK: - Tap handling
        /// 탭한 지점 좌표를 뷰모델에 전달하여 최근접 구역 선택
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let mapView else { return }
            if gesture.state == .ended {
                let location = gesture.location(in: mapView)
                let coord = mapView.convert(location, toCoordinateFrom: mapView)
                viewModel?.pickNearestZone(to: coord)
            }
        }

        /// 어노테이션 뷰 - single canvas host for all stations/conquer buttons
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard annotation is CanvasAnnotation else { return nil }
          
            let id = "canvas-hosting-full"
            let view: HostingAnnotationView
            if let reused = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? HostingAnnotationView {
                view = reused
                view.annotation = annotation
            } else {
                view = HostingAnnotationView(annotation: annotation, reuseIdentifier: id)
            }

            // Ensure positions are up-to-date for current map bounds
            updatePositions(for: mapView)
            let canvasSize = mapView.bounds.size

            let swiftUIView = ZStack {
                // TODO: 제거 예정
//                // Station buttons (위에 보이도록)
//                ForEach(positioned) { item in
//                    ZoneStation(
//                        zone: item.zone,
//                        statusesForZone: item.statusesForZone,
//                        zoneTeamScores: self.viewModel?.zoneTeamScores ?? [:],
//                        loadZoneTeamScores: { zoneId in
//                        Task { await self.viewModel?.loadZoneTeamScores(for: zoneId) }
//                        },
//                        iconSize: CGSize(width: 28, height: 32),
//                        popoverOffsetY: -84
//                    )
//                    .position(x: item.point.x, y: item.point.y)
//                }
                // Conquer buttons (기존 offset(y:-100)과 동일)
                ForEach(positioned.filter { $0.needsClaim }) { item in
                    ConqueredButton(zoneId: item.zone.zoneId) { ZoneConquerActionHandler.handleConquer(zoneId: $0) }
                        .position(x: item.point.x, y: item.point.y - 100)
                        .zIndex(1)
                    }
            }
            .frame(width: canvasSize.width, height: canvasSize.height)

            view.setSwiftUIView(swiftUIView)
            view.contentSize = canvasSize
            view.centerOffset = .zero
            view.canShowCallout = false
            view.isUserInteractionEnabled = true
            return view
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

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
        
        map.isScrollEnabled = false
        map.isZoomEnabled = false
        map.isRotateEnabled = false
        map.isPitchEnabled = false
        map.showsUserLocation = true
        
        let config = MKStandardMapConfiguration(elevationStyle: .flat)
        config.pointOfInterestFilter = .excludingAll
        config.showsTraffic = false
        map.preferredConfiguration = config
        
        let region = bounds.region
        map.setRegion(region, animated: true)
        map.delegate = context.coordinator
        context.coordinator.mapView = map
        context.coordinator.request()
        
        context.coordinator.conquestStatuses = conquestStatuses
        context.coordinator.zoneStatuses = zoneStatuses
        context.coordinator.teams = teams
        context.coordinator.mode = mode
        context.coordinator.viewModel = viewModel
        
        MapElementInstaller.installOverlays(for: zones, on: map)
        #if DEBUG
        MapElementInstaller.installDebugGateCircles(for: zones, on: map)
        #endif
        // Add a single canvas annotation at the map center
        let center = bounds.center
        map.addAnnotation(CanvasAnnotation(coordinate: center))
        
        // 제스처: 드래그 종료 지점에서 구역 선택
        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        pan.cancelsTouchesInView = false
        map.addGestureRecognizer(pan)
        
        // 제스처: 탭 지점에서 구역 선택
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tap.cancelsTouchesInView = false
        map.addGestureRecognizer(tap)
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 모드/데이터 변경 시 렌더러 색상만 갱신 (오버레이 재생성 금지)
        context.coordinator.conquestStatuses = conquestStatuses
        context.coordinator.zoneStatuses = zoneStatuses
        context.coordinator.teams = teams
        context.coordinator.mode = mode
        DispatchQueue.main.async {
            for overlay in uiView.overlays {
                guard let line = overlay as? ColoredPolyline,
                      let renderer = uiView.renderer(for: overlay)
                        as? MKPolylineRenderer
                else { continue }
                switch mode {
                case .overall:
                    let stroke = ZoneColorResolver.leadingColorOrDefault(
                        for: line.zoneId,
                        zoneStatuses: zoneStatuses,
                        defaultColor: .primaryGreen
                    )
                    renderer.strokeColor = stroke
                case .personal:
                    let checked =
                    StatusManager.shared.userStatus.zoneCheckedStatus[
                        line.zoneId
                    ] == true
                    if checked {
                        let teamName = StatusManager.shared.userStatus.userTeam
                        let personalColor: UIColor
                        switch teamName {
                        case "Blue":
                            personalColor = .subA
                        case "Yellow":
                            personalColor = .subB
                        default:
                            personalColor = .primaryGreen
                        }
                        renderer.strokeColor = personalColor
                    } else {
                        renderer.strokeColor = .primaryGreen
                    }
                }
                renderer.setNeedsDisplay()
            }

            // Refresh the single canvas annotation's view for all stations/conquer buttons
            guard let canvas = uiView.annotations.first(where: { $0 is CanvasAnnotation }),
                  let view = uiView.view(for: canvas) as? HostingAnnotationView else { return }
          
            context.coordinator.updatePositions(for: uiView)
            let canvasSize = uiView.bounds.size
          
            let swiftUIView = ZStack {
                // TODO: 제거 예정
//                ForEach(context.coordinator.positioned) { item in
//                    ZoneStation(
//                        zone: item.zone,
//                        statusesForZone: item.statusesForZone,
//                        zoneTeamScores: viewModel.zoneTeamScores,
//                        loadZoneTeamScores: { zoneId in
//                            Task { await self.viewModel.loadZoneTeamScores(for: zoneId) }
//                        },
//                        iconSize: CGSize(width: 28, height: 32),
//                        popoverOffsetY: -84
//                    )
//                    .position(x: item.point.x, y: item.point.y)
//                }
                ForEach(context.coordinator.positioned.filter { $0.needsClaim }) { item in
                    ConqueredButton(zoneId: item.zone.zoneId) { ZoneConquerActionHandler.handleConquer(zoneId: $0) }
                        .position(x: item.point.x, y: item.point.y - 100)
                        .zIndex(1)
                }
            }
            .frame(width: canvasSize.width, height: canvasSize.height)
            view.setSwiftUIView(swiftUIView)
            view.contentSize = canvasSize
            view.centerOffset = .zero
        }
    }
}

// MARK: - FullMapScreen

struct FullMapScreen: View {
    @StateObject private var viewModel = MapScreenViewModel()
    
    @State private var isRightSelected = false
    @State private var effectiveToken: UUID = .init()
    @State private var selectedZone: Zone?
    let conquestStatuses: [ZoneConquestStatus]
    let teams: [Team]
    let refreshToken: UUID
    let userStatus: UserStatus
    let period: ConquestPeriod
    
    init(
        conquestStatuses: [ZoneConquestStatus],
        teams: [Team],
        refreshToken: UUID,
        userStatus: UserStatus = StatusManager.shared.userStatus,
        period: ConquestPeriod
    ) {
        self.conquestStatuses = conquestStatuses
        self.period = period
        self.teams = teams
        self.refreshToken = refreshToken
        self.userStatus = userStatus
    }
    
    var body: some View {
        FullMapView(
            viewModel: viewModel,
            zoneStatuses: viewModel.zoneStatuses,
            conquestStatuses: conquestStatuses,
            teams: teams,
            mode: isRightSelected ? .personal : .overall,
            refreshToken: effectiveToken
        )
        .ignoresSafeArea()
        .task {
            // 팀 정보 보정 후 맵 데이터 로드
            await StatusManager.shared.ensureUserTeamLoaded()
            await viewModel.loadMapInfo()
        }
        .sheet(item: $viewModel.selectedZone) { z in
            ZoneInfoView(
                zone: z,
                teamScores: viewModel.zoneTeamScores[z.zoneId] ?? [],
                descriptionText: z.description
            )
            .task {
                await viewModel.loadZoneTeamScores(for: z.zoneId)
            }
        }
        .onAppear {
            // 부모에서 전달받은 토큰을 항상 채택
            effectiveToken = refreshToken
        }
        .onChange(of: refreshToken) {
            // 부모 갱신 토큰 변화도 반영
            effectiveToken = refreshToken
        }
        // TODO: 임시 Notification 기반 업데이트
        .onReceive(NotificationCenter.default.publisher(for: ZoneConquerActionHandler.didUpdateScoreNotification)) { _ in
            Task { @MainActor in
                await viewModel.loadMapInfo()
            }
        }
        .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
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
                    
                    TodayMyScore(score: viewModel.userDailyScore)  // 오늘 내 점수
                }

                SegmentedControl(
                    leftTitle: "전체",
                    rightTitle: "개인",
                    frameMaxWidth: 172,
                    isRightSelected: $isRightSelected
                )
                .padding(.leading, -20)
            }
            .padding(.top, 60)
            .padding(.horizontal, 20)
            .task {
                await viewModel.loadMapInfo()
                viewModel.startDDayTimer(period: period)
            }
        }
//        .overlay(alignment: .bottomLeading) {
//#if DEBUG
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 8) {
//                    ForEach(1...15, id: \.self) { id in
//                        Button(action: {
//                            // 로컬 먼저 반영 (개인 지도 즉시 표시)
//                            StatusManager.shared.setZoneChecked(
//                                zoneId: id,
//                                checked: true
//                            )
//                            effectiveToken = UUID()
//                            // 서버 전송은 후행, 실패해도 로컬 상태 유지
//                            ZoneCheckedService.shared.postChecked(
//                                zoneId: id
//                            ) { ok in
//                                if !ok {
//                                    print(
//                                        "[DEBUG] 서버 전송 실패: zoneId=\(id) — 로컬 상태는 유지"
//                                    )
//                                }
//                            }
//                        }) {
//                            Text("#\(id)")
//                                .font(.PR.caption2)
//                                .foregroundColor(.white)
//                                .padding(.vertical, 6)
//                                .padding(.horizontal, 10)
//                                .background(Color.black.opacity(0.6))
//                                .clipShape(Capsule())
//                        }
//                    }
//                }
//                .padding(.horizontal, 12)
//                .padding(.vertical, 10)
//            }
//            .background(
//                Color.black.opacity(0.15)
//                    .blur(radius: 2)
//            )
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//            .padding(.leading, 16)
//            .padding(.bottom, 120)
//            .onAppear {
//                // 최초 진입 시, 부모에서 전달받은 토큰을 채택
//                effectiveToken = refreshToken
//            }
//            .onChange(of: refreshToken) { newValue in
//                // 부모 갱신 토큰 변화도 반영
//                effectiveToken = newValue
//            }
//#endif
//        }
//        .overlay(alignment: .topTrailing) {
//#if DEBUG
//            ZoneDebugOverlay()
//#endif
//        }
    }
}

