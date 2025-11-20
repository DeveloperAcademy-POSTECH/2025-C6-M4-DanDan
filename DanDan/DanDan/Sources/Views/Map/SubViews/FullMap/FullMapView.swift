//
//  FullMapView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/1/25.
//

import MapKit
import SwiftUI
import UIKit

// Canvas host annotation for overlaying station/conquer buttons in view space
final class CanvasAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    init(coordinate: CLLocationCoordinate2D) { self.coordinate = coordinate }
}

// 드래그 하이라이트용 임시 폴리라인
final class HighlightedPolyline: MKPolyline {
    var zoneId: Int = 0
    var isInner: Bool = false
}

// 드래그 하이라이트용 내부 채움 폴리곤
final class HighlightedPolygon: MKPolygon {
    var zoneId: Int = 0
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
        
        // 시트 종료 알림
        static let sheetDismissedNotification = Notification.Name("FullMapView.Coordinator.sheetDismissed")
        
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
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(onSheetDismissed),
                name: Self.sheetDismissedNotification,
                object: nil
            )
        }
        
        func request() {
            manager.requestWhenInUseAuthorization()
        }
        
        func updatePositions(for mapView: MKMapView) {
            // Convert each zone centroid to view-space point
            let mapped: [PositionedStation] = zones.map { z in
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
            // y가 클수록(화면 아래쪽) 위에 보이도록 렌더 순서를 정렬
            positioned = mapped.sorted { $0.point.y < $1.point.y }
        }
        
        // MARK: - MKMapViewDelegate
        
        /// 오버레이(폴리라인/디버그 원) 렌더러 - 구역별 색/굵기 등 스타일 지정
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let poly = overlay as? HighlightedPolygon {
                let r = MKPolygonRenderer(polygon: poly)
                let fill: UIColor
                switch mode {
                case .overall:
                    fill = ZoneColorResolver.leadingColorOrDefault(
                        for: poly.zoneId,
                        zoneStatuses: zoneStatuses,
                        defaultColor: .primaryGreen
                    ).withAlphaComponent(0.22)
                case .personal:
                    let checked = StatusManager.shared.userStatus.zoneCheckedStatus[poly.zoneId] == true
                    if checked {
                        let teamName = StatusManager.shared.userStatus.userTeam
                        switch teamName {
                        case "Blue":
                            fill = UIColor.subA.withAlphaComponent(0.22)
                        case "Yellow":
                            fill = UIColor.subB.withAlphaComponent(0.22)
                        default:
                            fill = UIColor.primaryGreen.withAlphaComponent(0.22)
                        }
                    } else {
                        fill = UIColor.primaryGreen.withAlphaComponent(0.22)
                    }
                }
                r.fillColor = fill
                r.strokeColor = UIColor.clear
                r.lineWidth = 0
                return r
            }
            if let hl = overlay as? HighlightedPolyline {
                let r = MKPolylineRenderer(overlay: hl)
                // 드래그/탭 하이라이트: 외곽선 없이 단일 선
                r.strokeColor = UIColor.darkGreen
                r.lineWidth = 16
                r.lineCap = .round
                r.lineJoin = .round
                return r
            }
            //            if let circle = overlay as? MKCircle {
            //                let r = MKCircleRenderer(overlay: circle)
            //                #if DEBUG
            //                let title = circle.title ?? ""
            //                if title.contains("debug-circle-start") {
            //                    r.strokeColor = UIColor.systemRed.withAlphaComponent(0.9)
            //                    r.fillColor = UIColor.systemRed.withAlphaComponent(0.06)
            //                } else {
            //                    r.strokeColor = UIColor.systemBlue.withAlphaComponent(0.9)
            //                    r.fillColor = UIColor.systemBlue.withAlphaComponent(0.06)
            //                }
            //                r.lineWidth = 2
            //                if title.hasSuffix("-out") {
            //                    r.lineDashPattern = [6, 6]
            //                }
            //                #endif
            //                return r
            //            }
            
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
            case .began:
                UISelectionFeedbackGenerator().prepare()
            case .changed:
                let coord = mapView.convert(location, toCoordinateFrom: mapView)
                if let nearest = nearestZoneId(to: coord) {
                    if nearest != (highlightedOuter?.zoneId ?? -1) {
                        UISelectionFeedbackGenerator().selectionChanged()
                        setHighlightedZone(nearest, on: mapView)
                    }
                }
            case .ended:
                let coord = mapView.convert(location, toCoordinateFrom: mapView)
                // 마지막으로 하이라이트된 구역을 우선 사용 (손 위치와 무관하게 그 구역 정보 표시)
                let lastZoneId = highlightedOuter?.zoneId ?? highlightedInner?.zoneId
                if let zId = lastZoneId ?? nearestZoneId(to: coord),
                   let zone = zones.first(where: { $0.zoneId == zId })
                {
                    setHighlightedZone(zId, on: mapView)
                    let center = parent.centroid(of: zone.coordinates)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    DispatchQueue.main.async { [weak self] in
                        self?.viewModel?.pickNearestZone(to: center)
                    }
                } else {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    DispatchQueue.main.async { [weak self] in
                        self?.viewModel?.pickNearestZone(to: coord)
                    }
                }
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
                if let nearest = nearestZoneId(to: coord),
                   let zone = zones.first(where: { $0.zoneId == nearest })
                {
                    setHighlightedZone(nearest, on: mapView)
                    let center = parent.centroid(of: zone.coordinates)
                    UISelectionFeedbackGenerator().selectionChanged()
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    DispatchQueue.main.async { [weak self] in
                        self?.viewModel?.pickNearestZone(to: center)
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        self?.viewModel?.pickNearestZone(to: coord)
                    }
                }
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
                // Conquer buttons
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
        
        // MARK: - Highlight helpers
        
        private var highlightedOuter: HighlightedPolyline?
        private var highlightedInner: HighlightedPolyline?
        private var highlightedFill: HighlightedPolygon?
        
        // 선택 가능한 구역(1~15)으로 제한
        private var selectableZones: [Zone] {
            zones.filter { (1...15).contains($0.zoneId) }
        }
        
        private func nearestZoneId(to coord: CLLocationCoordinate2D) -> Int? {
            guard !selectableZones.isEmpty else { return nil }
            var bestId: Int?
            var bestDistance: CLLocationDistance = .greatestFiniteMagnitude
            let target = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            for z in selectableZones {
                let c = parent.centroid(of: z.coordinates)
                let d = target.distance(from: CLLocation(latitude: c.latitude, longitude: c.longitude))
                if d < bestDistance {
                    bestDistance = d
                    bestId = z.zoneId
                }
            }
            return bestId
        }
        
        private func setHighlightedZone(_ zoneId: Int?, on mapView: MKMapView) {
            if let outer = highlightedOuter {
                mapView.removeOverlay(outer)
                highlightedOuter = nil
            }
            if let inner = highlightedInner {
                mapView.removeOverlay(inner)
                highlightedInner = nil
            }
            if let fill = highlightedFill {
                mapView.removeOverlay(fill)
                highlightedFill = nil
            }
            guard let zoneId else { return }
            guard let zone = zones.first(where: { $0.zoneId == zoneId }) else { return }
            // 바깥선(흰색)
            let outer = HighlightedPolyline(coordinates: zone.coordinates, count: zone.coordinates.count)
            outer.zoneId = zone.zoneId
            outer.isInner = false
            // 안쪽선(기존 색, 기존 선 두께)
            let inner = HighlightedPolyline(coordinates: zone.coordinates, count: zone.coordinates.count)
            inner.zoneId = zone.zoneId
            inner.isInner = true
            // 내부 채움(폴리곤)
            let fill = HighlightedPolygon(coordinates: zone.coordinates, count: zone.coordinates.count)
            fill.zoneId = zone.zoneId
            highlightedOuter = outer
            highlightedInner = inner
            highlightedFill = fill
            // 순서: 바깥선 → 안쪽선 → 채움(위에 올려 겹침)
            mapView.addOverlay(outer, level: .aboveRoads)
            mapView.addOverlay(inner, level: .aboveRoads)
            mapView.addOverlay(fill, level: .aboveRoads)
        }
        
        @objc private func onSheetDismissed() {
            guard let mapView else { return }
            setHighlightedZone(nil, on: mapView)
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
        
        var region = bounds.region
        
        // 지도 아래로 내리기
        let shift = region.span.latitudeDelta * 0.1
        region.center.latitude += shift
        
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
                ForEach(context.coordinator.positioned.filter { $0.needsClaim }) { item in
                    ConqueredButton(zoneId: item.zone.zoneId) { ZoneConquerActionHandler.handleConquer(zoneId: $0) }
                        .position(x: item.point.x - 20, y: item.point.y - 40)
                        .zIndex(Double(item.point.y))
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
        ZStack(alignment: .top) {
            // 2D 전체 지도
            FullMapView(
                viewModel: viewModel,
                zoneStatuses: viewModel.zoneStatuses,
                conquestStatuses: conquestStatuses,
                teams: teams,
                mode: isRightSelected ? .personal : .overall,
                refreshToken: effectiveToken
            )
            .ignoresSafeArea()
            
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
            .padding(.vertical, 58)
            .padding(.horizontal, 20)
        }
        .task {
            // 팀 정보 보정 후 맵 데이터 로드
            await StatusManager.shared.ensureUserTeamLoaded()
            await viewModel.loadMapInfo()
        }
        .sheet(item: $viewModel.selectedZone) { z in
            ZoneInfoView(
                zone: z,
                teamScores: viewModel.zoneTeamScores[z.zoneId] ?? []
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
        // 시트 종료 시 하이라이트 제거 (Equatable 요구 회피: zoneId 기반)
        .onChange(of: viewModel.selectedZone?.zoneId ?? -1) { newValue in
            if newValue == -1 {
                NotificationCenter.default.post(name: FullMapView.Coordinator.sheetDismissedNotification, object: nil)
            }
        }
        
        
        
        
    //        .overlay(alignment: .topLeading) {
    //            VStack(alignment: .leading, spacing: 6) {
    //                HStack(spacing: 4) {
    //                    if viewModel.teams.count >= 2 {
    //                        ScoreBoard(
    //                            leftTeamName: viewModel.teams[1].teamName,
    //                            rightTeamName: viewModel.teams[0].teamName,
    //                            leftTeamScore: viewModel.teams[1].conqueredZones,
    //                            rightTeamScore: viewModel.teams[0].conqueredZones,
    //                            ddayText: viewModel.ddayText
    //                        )
    //                    } else {
    //                        // 로딩 중일 때는 기본값 표시
    //                        ScoreBoard(
    //                            leftTeamName: "—",
    //                            rightTeamName: "—",
    //                            leftTeamScore: 0,
    //                            rightTeamScore: 0,
    //                            ddayText: viewModel.ddayText
    //                        )
    //                    }
    //
    //                    Spacer()
    //
    //                    TodayMyScore(score: viewModel.userDailyScore)  // 오늘 내 점수
    //                }
    //
    //                SegmentedControl(
    //                    leftTitle: "전체",
    //                    rightTitle: "개인",
    //                    frameMaxWidth: 172,
    //                    isRightSelected: $isRightSelected
    //                )
    //                .padding(.leading, -20)
    //            }
    //            .padding(.top, 60)
    //            .padding(.horizontal, 20)
    //            .task {
    //                await viewModel.loadMapInfo()
    //                viewModel.startDDayTimer(period: period)
    //            }
    //        }
    
    
    
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
    // #if DEBUG
    //            ZoneDebugOverlay()
    // #endif
    //        }
    }
}

