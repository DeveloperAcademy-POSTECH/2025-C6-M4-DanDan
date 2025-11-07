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
    enum Mode { case overall, personal }
    let conquestStatuses: [ZoneConquestStatus]
    let teams: [Team]
    var mode: Mode = .overall
    // 외부 상태 변경에 따른 갱신 트리거용 토큰
    var refreshToken: UUID = .init()
    
    // MARK: - Bounds

    /// 철길숲의 남서쪽과 북동쪽 좌표를 기준으로 지도 표시 범위를 계산하는 내부 구조체
    struct Bounds {
        let southWest: CLLocationCoordinate2D
        let northEast: CLLocationCoordinate2D
        let margin: Double = 1.35
        
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
                center: center,
                span: MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon)
            )
        }
        
        var span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    }
    
    /// 구역 중심 좌표 계산
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
    
    final class ColoredPolyline: MKPolyline {
        var color: UIColor = .white
        var isOutline: Bool = false
        var zoneId: Int = 0
    }
    
    final class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        let manager = CLLocationManager()
        
        var conquestStatuses: [ZoneConquestStatus] = []
        var teams: [Team] = []
        var mode: Mode = .overall
        
        override init() {
            super.init()
            manager.delegate = self
        }
        
        func request() {
            manager.requestWhenInUseAuthorization()
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let line = overlay as? ColoredPolyline else { return MKOverlayRenderer() }
            let renderer = MKPolylineRenderer(overlay: line)

            let stroke: UIColor
            switch mode {
            case .overall:
                stroke = ZoneColorResolver.leadingColorOrDefault(
                    for: line.zoneId,
                    in: conquestStatuses,
                    teams: teams,
                    defaultColor: .primaryGreen
                )
            case .personal:
                let checked = StatusManager.shared.userStatus.zoneCheckedStatus[line.zoneId] == true
                if checked {
                    stroke = ZoneColorResolver.leadingColorOrDefault(
                        for: line.zoneId,
                        in: conquestStatuses,
                        teams: teams,
                        defaultColor: .primaryGreen
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
        
        // 정류소 버튼 주입(작은 크기)
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let ann = annotation as? StationAnnotation else { return nil }
            
            let id = "station-hosting-full"
            let view: HostingAnnotationView
            if let reused = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? HostingAnnotationView {
                view = reused
                view.annotation = ann
            } else {
                view = HostingAnnotationView(annotation: ann, reuseIdentifier: id)
            }
            
            let swiftUIView = ZoneStationButton(
                zone: ann.zone,
                statusesForZone: ann.statusesForZone,
                iconSize: CGSize(width: 28, height: 32), 
                popoverOffsetY: -84
            )
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
        
        for zone in zones {
            let coords = zone.coordinates
            
            let c = centroid(of: coords)
            let statuses = conquestStatuses.filter { $0.zoneId == zone.zoneId }
            let ann = StationAnnotation(coordinate: c, zone: zone, statusesForZone: statuses)
            map.addAnnotation(ann)
            
            let polyline = ColoredPolyline(coordinates: coords, count: coords.count)
            polyline.zoneId = zone.zoneId
            polyline.color = zone.zoneColor
            map.addOverlay(polyline)
        }
        
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
                      let renderer = uiView.renderer(for: overlay) as? MKPolylineRenderer else { continue }
                switch mode {
                case .overall:
                    let stroke = ZoneColorResolver.leadingColorOrDefault(
                        for: line.zoneId,
                        in: conquestStatuses,
                        teams: teams,
                        defaultColor: .primaryGreen
                    )
                    renderer.strokeColor = stroke
                case .personal:
                    let checked = StatusManager.shared.userStatus.zoneCheckedStatus[line.zoneId] == true
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
        }
    }
}
struct FullMapScreen: View {
    @State private var isRightSelected = false
    @State private var effectiveToken: UUID = UUID()
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
            conquestStatuses: conquestStatuses,
            teams: teams,
            mode: isRightSelected ? .personal : .overall,
            refreshToken: effectiveToken
        )
            .ignoresSafeArea()
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 6) {
                    ScoreBoardView(statuses: conquestStatuses, teams: teams)
                        .padding(.leading, 20)

                    SegmentedControl(
                        leftTitle: "전체",
                        rightTitle: "개인",
                        frameMaxWidth: 172,
                        isRightSelected: $isRightSelected
                    )
                }
                .padding(.top, 60)
            }
//            .overlay(alignment: .bottomLeading) {
//                #if DEBUG
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 8) {
//                        ForEach(1...15, id: \.self) { id in
//                            Button(action: {
//                                // 로컬 먼저 반영 (개인 지도 즉시 표시)
//                                StatusManager.shared.setZoneChecked(zoneId: id, checked: true)
//                                effectiveToken = UUID()
//                                // 서버 전송은 후행, 실패해도 로컬 상태 유지
//                                ZoneCheckedService.shared.postChecked(zoneId: id) { ok in
//                                    if !ok {
//                                        print("[DEBUG] 서버 전송 실패: zoneId=\(id) — 로컬 상태는 유지")
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
//                #endif
//            }
    }
}

// #if DEBUG
// #Preview("FullMap · Overall vs Personal") {
//     let demoTeams: [Team] = [
//         .init(id: UUID(), teamName: "white", teamColor: "SubA"),
//         .init(id: UUID(), teamName: "blue", teamColor: "SubB")
//     ]
//     // zones 중 일부에 더미 승자 배정
//     let demoStatuses: [ZoneConquestStatus] = zones.prefix(10).enumerated().map { idx, z in
//         let winner = (idx % 2 == 0) ? "white" : "blue"
//         return ZoneConquestStatus(zoneId: z.zoneId, teamId: idx % 2, teamName: winner, teamScore: 10 + idx)
//     }

//     VStack(spacing: 12) {
//         Text("Overall")
//             .font(.PR.caption2)
//             .foregroundColor(.gray2)
//         FullMapView(conquestStatuses: demoStatuses, teams: demoTeams, mode: .overall)
//             .frame(height: 220)
//             .clipShape(RoundedRectangle(cornerRadius: 12))

//         Text("Personal (임의로 짝수 구역만 완료로 가정)")
//             .font(.PR.caption2)
//             .foregroundColor(.gray2)
//         FullMapView(conquestStatuses: demoStatuses, teams: demoTeams, mode: .personal)
//             .frame(height: 220)
//             .clipShape(RoundedRectangle(cornerRadius: 12))
//     }
//     .padding()
//     .task {
//         // 짝수 zoneId만 완료로 가정 (미리보기용 사이드 이펙트)
//         for status in demoStatuses {
//             if status.zoneId % 2 == 0 {
//                 StatusManager.shared.setZoneChecked(zoneId: status.zoneId, checked: true)
//             } else {
//                 StatusManager.shared.setZoneChecked(zoneId: status.zoneId, checked: false)
//             }
//         }
//     }
// }
// #endif
