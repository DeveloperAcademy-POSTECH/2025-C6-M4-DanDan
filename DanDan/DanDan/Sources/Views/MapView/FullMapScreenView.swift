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

    let conquestStatuses: [ZoneConquestStatus]
    let teams: [Team]

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
            let spanLon =
                abs(northEast.longitude - southWest.longitude) * margin
            return MKCoordinateRegion(
                center: self.center,
                span: MKCoordinateSpan(
                    latitudeDelta: spanLat,
                    longitudeDelta: spanLon
                )
            )
        }

        var span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    }

    /// 구역 중심 좌표 계산
    private func centroid(of coords: [CLLocationCoordinate2D])
        -> CLLocationCoordinate2D
    {
        guard !coords.isEmpty else { return bounds.center }
        let lat = coords.map { $0.latitude }.reduce(0, +) / Double(coords.count)
        let lon =
            coords.map { $0.longitude }.reduce(0, +) / Double(coords.count)
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

    final class Coordinator: NSObject, MKMapViewDelegate,
        CLLocationManagerDelegate
    {
        let manager = CLLocationManager()

        var conquestStatuses: [ZoneConquestStatus] = []
        var teams: [Team] = []

        override init() {
            super.init()
            manager.delegate = self
        }

        func request() {
            manager.requestWhenInUseAuthorization()
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay)
            -> MKOverlayRenderer
        {
            guard let line = overlay as? ColoredPolyline else {
                return MKOverlayRenderer()
            }
            let renderer = MKPolylineRenderer(overlay: line)

            let stroke = ZoneColorResolver.leadingColorOrDefault(
                for: line.zoneId,
                in: conquestStatuses,
                teams: teams,
                defaultColor: .primaryGreen  // line.color
            )
            renderer.strokeColor = stroke
            renderer.lineWidth = 16
            renderer.lineCap = .round
            renderer.lineJoin = .round
            return renderer
        }

        // 정류소 버튼 주입(작은 크기)
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)
            -> MKAnnotationView?
        {
            guard let ann = annotation as? StationAnnotation else { return nil }

            let id = "station-hosting-full"
            let view: HostingAnnotationView
            if let reused = mapView.dequeueReusableAnnotationView(
                withIdentifier: id
            ) as? HostingAnnotationView {
                view = reused
                view.annotation = ann
            } else {
                view = HostingAnnotationView(
                    annotation: ann,
                    reuseIdentifier: id
                )
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

        for zone in zones {
            let coords = zone.coordinates

            let c = centroid(of: coords)
            let statuses = conquestStatuses.filter { $0.zoneId == zone.zoneId }
            let ann = StationAnnotation(
                coordinate: c,
                zone: zone,
                statusesForZone: statuses
            )
            map.addAnnotation(ann)

            let polyline = ColoredPolyline(
                coordinates: coords,
                count: coords.count
            )
            polyline.zoneId = zone.zoneId
            polyline.color = zone.zoneColor
            map.addOverlay(polyline)
        }

        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {}
}

struct FullMapScreenView: View {
    @StateObject private var viewModel = MapScreenViewModel()
    
    @State private var isRightSelected = false
    let conquestStatuses: [ZoneConquestStatus]
    let teams: [Team]
    let userStatus: UserStatus

    var body: some View {
        FullMapView(conquestStatuses: conquestStatuses, teams: teams)
            .ignoresSafeArea()
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        if viewModel.teams.count >= 2 {
                            ScoreBoardView(
                                leftTeamName: viewModel.teams[0].teamName,
                                rightTeamName: viewModel.teams[1].teamName,
                                leftTeamScore: viewModel.teams[0]
                                    .conqueredZones,
                                rightTeamScore: viewModel.teams[1]
                                    .conqueredZones
                            )
                        } else {
                            // 로딩 중일 때는 기본값 표시
                            ScoreBoardView(
                                leftTeamName: "—",
                                rightTeamName: "—",
                                leftTeamScore: 0,
                                rightTeamScore: 0
                            )
                        }
                        TodayMyScore(status: userStatus)  // 오늘 내 점수
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
    }
}
