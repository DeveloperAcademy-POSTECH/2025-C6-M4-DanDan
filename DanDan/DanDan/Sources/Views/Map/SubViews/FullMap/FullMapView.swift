//
//  FullMapView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/1/25.
//

import MapKit
import SwiftUI

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

        override init() {
            super.init()
            manager.delegate = self
        }

        func request() {
            manager.requestWhenInUseAuthorization()
        }
        
        // MARK: - MKMapViewDelegate
        /// 오버레이(폴리라인) 렌더러 - 구역별 색/굵기 등 스타일 지정
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) ->
        MKOverlayRenderer {
            guard let line = overlay as? ColoredPolyline else {
                return MKOverlayRenderer()
            }
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
                    stroke = ZoneColorResolver.leadingColorOrDefault(
                        for: line.zoneId,
                        in: conquestStatuses,
                        teams: teams,
                        defaultColor: .subA
                    )
                } else {
                    stroke = UIColor.clear
                }
            }
            renderer.strokeColor = stroke
            renderer.lineWidth = 16
            renderer.lineCap = .round
            renderer.lineJoin = .round
            return renderer
        }
        
        /// 어노테이션 뷰 - 정류소 버튼(작은 크기) + 정복 버튼 주입
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) ->
            MKAnnotationView? {
            guard let ann = annotation as? StationAnnotation else { return nil }

            let id = "station-hosting-full"
            let view: HostingAnnotationView
            if let reused = mapView.dequeueReusableAnnotationView(withIdentifier: id)
                as? HostingAnnotationView {
                view = reused
                view.annotation = ann
            } else {
                view = HostingAnnotationView(annotation: ann,reuseIdentifier: id)
            }

            let isChecked =
                StatusManager.shared.userStatus.zoneCheckedStatus[ann.zone.zoneId] == true
            let isClaimed = StatusManager.shared.isRewardClaimed(zoneId: ann.zone.zoneId)
                
            let swiftUIView = ZStack {
                ZoneStationButton(
                    viewModel: viewModel ?? MapScreenViewModel(),
                    zone: ann.zone,
                    statusesForZone: ann.statusesForZone,
                    iconSize: CGSize(width: 28, height: 32),
                    popoverOffsetY: -84
                )

                if isChecked && !isClaimed {
                    ConqueredButton(zoneId: ann.zone.zoneId) { ZoneConquerActionHandler.handleConquer(zoneId: $0) }
                    .offset(y: -100)
                }
            }
            view.setSwiftUIView(swiftUIView)
            view.contentSize = CGSize(width: 120, height: 140)
            view.centerOffset = CGPoint(x: 0, y: -40)
            view.canShowCallout = false
            view.isUserInteractionEnabled = true
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
        context.coordinator.request()

        context.coordinator.conquestStatuses = conquestStatuses
        context.coordinator.teams = teams
        context.coordinator.mode = mode
        context.coordinator.viewModel = viewModel

        MapElementInstaller.installOverlays(for: zones, on: map)
        MapElementInstaller.installStations(
            for: zones,
            statuses: conquestStatuses,
            centroidOf: centroid(of:),
            on: map
        )
        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 모드/데이터 변경 시 렌더러 색상만 갱신 (오버레이 재생성 금지)
        context.coordinator.conquestStatuses = conquestStatuses
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
                        let stroke = ZoneColorResolver.leadingColorOrDefault(
                            for: line.zoneId,
                            in: conquestStatuses,
                            teams: teams,
                            defaultColor: .subA
                        )
                        renderer.strokeColor = stroke
                    } else {
                        renderer.strokeColor = .primaryGreen
                    }
                }
                renderer.setNeedsDisplay()
            }

            // 주석(정류소) 콘텐츠도 최신 상태로 갱신
            for annotation in uiView.annotations {
                guard let ann = annotation as? StationAnnotation,
                    let view = uiView.view(for: ann) as? HostingAnnotationView
                else { continue }
                let isChecked =
                    StatusManager.shared.userStatus.zoneCheckedStatus[
                        ann.zone.zoneId
                    ] == true
                let isClaimed = StatusManager.shared.isRewardClaimed(
                    zoneId: ann.zone.zoneId
                )
                let swiftUIView = ZStack {
                    ZoneStationButton(
                        viewModel: viewModel,
                        zone: ann.zone,
                        statusesForZone: ann.statusesForZone,
                        iconSize: CGSize(width: 28, height: 32),
                        popoverOffsetY: -84
                    )
                    if isChecked && !isClaimed {
                        ConqueredButton(zoneId: ann.zone.zoneId) { ZoneConquerActionHandler.handleConquer(zoneId: $0) }
                        .offset(y: -100)
                    }
                }
                view.setSwiftUIView(swiftUIView)
            }
        }
    }
}

struct FullMapScreen: View {
    @StateObject private var viewModel = MapScreenViewModel()

    @State private var isRightSelected = false
    @State private var effectiveToken: UUID = .init()
    let conquestStatuses: [ZoneConquestStatus]
    let teams: [Team]
    let refreshToken: UUID
    let userStatus: UserStatus

    init(
        conquestStatuses: [ZoneConquestStatus],
        teams: [Team],
        refreshToken: UUID,
        userStatus: UserStatus = StatusManager.shared.userStatus
    ) {
        self.conquestStatuses = conquestStatuses
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
            await viewModel.loadMapInfo()
        }
        .onAppear {
            // 부모에서 전달받은 토큰을 항상 채택
            effectiveToken = refreshToken
        }
        .onChange(of: refreshToken) {
            // 부모 갱신 토큰 변화도 반영
            effectiveToken = refreshToken
        }
        .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    if viewModel.teams.count >= 2 {
                        ScoreBoard(
                            leftTeamName: viewModel.teams[1].teamName,
                            rightTeamName: viewModel.teams[0].teamName,
                            leftTeamScore: viewModel.teams[1]
                                .conqueredZones,
                            rightTeamScore: viewModel.teams[0]
                                .conqueredZones
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
                
                SegmentedControl(
                    leftTitle: "전체",
                    rightTitle: "개인",
                    frameMaxWidth: 172,
                    isRightSelected: $isRightSelected
                )
                .padding(.leading, -20)
            }
            .padding(.top, 60)
            .padding(.leading, 14)
            .task {
                await viewModel.loadMapInfo()
            }
        }
//        .overlay(alignment: .bottomLeading) {
//            #if DEBUG
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 8) {
//                        ForEach(1...15, id: \.self) { id in
//                            Button(action: {
//                                // 로컬 먼저 반영 (개인 지도 즉시 표시)
//                                StatusManager.shared.setZoneChecked(
//                                    zoneId: id,
//                                    checked: true
//                                )
//                                effectiveToken = UUID()
//                                // 서버 전송은 후행, 실패해도 로컬 상태 유지
//                                ZoneCheckedService.shared.postChecked(
//                                    zoneId: id
//                                ) { ok in
//                                    if !ok {
//                                        print(
//                                            "[DEBUG] 서버 전송 실패: zoneId=\(id) — 로컬 상태는 유지"
//                                        )
//                                    }
//                                }
//                            }) {
//                                Text("#\(id)")
//                                    .font(.PR.caption2)
//                                    .foregroundColor(.white)
//                                    .padding(.vertical, 6)
//                                    .padding(.horizontal, 10)
//                                    .background(Color.black.opacity(0.6))
//                                    .clipShape(Capsule())
//                            }
//                        }
//                    }
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 10)
//                }
//                .background(
//                    Color.black.opacity(0.15)
//                        .blur(radius: 2)
//                )
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//                .padding(.leading, 16)
//                .padding(.bottom, 20)
//                .onAppear {
//                    // 최초 진입 시, 부모에서 전달받은 토큰을 채택
//                    effectiveToken = refreshToken
//                }
//                .onChange(of: refreshToken) { newValue in
//                    // 부모 갱신 토큰 변화도 반영
//                    effectiveToken = newValue
//                }
//            #endif
//        }
    }
}
//
//#if DEBUG
//    #Preview("FullMap · Overall vs Personal") {
//        let demoTeams: [Team] = [
//            .init(id: UUID(), teamName: "white", teamColor: "SubA"),
//            .init(id: UUID(), teamName: "blue", teamColor: "SubB"),
//        ]
//        // zones 중 일부에 더미 승자 배정
//        let demoStatuses: [ZoneConquestStatus] = zones.prefix(10).enumerated()
//            .map { idx, z in
//                let winner = (idx % 2 == 0) ? "white" : "blue"
//                return ZoneConquestStatus(
//                    zoneId: z.zoneId,
//                    teamId: idx % 2,
//                    teamName: winner,
//                    teamScore: 10 + idx
//                )
//            }
//
//        VStack(spacing: 12) {
//            Text("Overall")
//                .font(.PR.caption2)
//                .foregroundColor(.gray2)
//            FullMapView(
//                zoneStatuses: viewModel.zoneStatuses,
//                conquestStatuses: demoStatuses,
//                teams: demoTeams,
//                mode: .overall
//            )
//            .frame(height: 220)
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//
//            Text("Personal (임의로 짝수 구역만 완료로 가정)")
//                .font(.PR.caption2)
//                .foregroundColor(.gray2)
//            FullMapView(
//                conquestStatuses: demoStatuses,
//                teams: demoTeams,
//                mode: .personal
//            )
//            .frame(height: 220)
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//        }
//        .padding()
//        .task {
//            // 짝수 zoneId만 완료로 가정 (미리보기용 사이드 이펙트)
//            for status in demoStatuses {
//                if status.zoneId % 2 == 0 {
//                    StatusManager.shared.setZoneChecked(
//                        zoneId: status.zoneId,
//                        checked: true
//                    )
//                } else {
//                    StatusManager.shared.setZoneChecked(
//                        zoneId: status.zoneId,
//                        checked: false
//                    )
//                }
//            }
//        }
//    }
//#endif
