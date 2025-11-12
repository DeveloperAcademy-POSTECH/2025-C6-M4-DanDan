//
//  MapManager.swift
//  DanDan
//
//  Created by soyeonsoo on 11/9/25.
//

import MapKit
import SwiftUI

final class ColoredPolyline: MKPolyline {
    var color: UIColor = .white
    var isOutline: Bool = false
    var zoneId: Int = 0
}

struct MapElementInstaller {
    /// 구역 폴리라인(기본/외곽선) 설치
    static func installOverlays(for zones: [Zone], on map: MKMapView) {
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

    /// 정류소 어노테이션 설치
    static func installStations(
        for zones: [Zone],
        statuses: [ZoneConquestStatus],
        centroidOf: ([CLLocationCoordinate2D]) -> CLLocationCoordinate2D,
        on map: MKMapView
    ) {
        for z in zones {
            let c = centroidOf(z.coordinates)
            let zoneStatuses = statuses.filter { $0.zoneId == z.zoneId }
            let ann = StationAnnotation(coordinate: c, zone: z, statusesForZone: zoneStatuses)
            map.addAnnotation(ann)
        }
    }
}

enum MapOverlayRefresher {
    static func refreshColors(on mapView: MKMapView, with provider: ZoneStrokeProvider) {
        for overlay in mapView.overlays {
            guard let line = overlay as? ColoredPolyline,
                  let renderer = mapView.renderer(for: overlay) as? MKPolylineRenderer else { continue }
            renderer.strokeColor = provider.stroke(for: line.zoneId, isOutline: line.isOutline)
            renderer.setNeedsDisplay()
        }
    }
}

final class ZoneConquerActionHandler {
    // TODO: 임시 Notification 기반 업데이트
    static let didUpdateScoreNotification = Notification.Name("ZoneConquerActionHandler.didUpdateScore")

    static func handleConquer(zoneId: Int) {
        ZoneCheckedService.shared.postChecked(zoneId: zoneId) { ok in
            guard ok else { print("🚨 postChecked failed: \(zoneId)"); return }
            ZoneCheckedService.shared.acquireScore(zoneId: zoneId) { ok2 in
                if ok2 {
                    StatusManager.shared.incrementDailyScore()
                    StatusManager.shared.setRewardClaimed(zoneId: zoneId, claimed: true)
                    
                    NotificationCenter.default.post(name: didUpdateScoreNotification, object: nil)
                } else {
                    print("🚨 acquireScore failed: \(zoneId)")
                }
            }
        }
    }
}

// SwiftUI 버튼을 얹기 위한 MKAnnotation
final class StationAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let zone: Zone
    let statusesForZone: [ZoneConquestStatus]
    
    init(coordinate: CLLocationCoordinate2D, zone: Zone, statusesForZone: [ZoneConquestStatus]) {
        self.coordinate = coordinate
        self.zone = zone
        self.statusesForZone = statusesForZone
    }
}

final class HostingAnnotationView: MKAnnotationView {
    private var host: UIHostingController<AnyView>?
    
    var contentSize: CGSize = .zero {
        didSet {
            self.frame = CGRect(origin: .zero, size: contentSize)
            setNeedsLayout()
        }
    }
    
    func setSwiftUIView<Content: View>(_ view: Content) {
        if host == nil {
            let controller = UIHostingController(rootView: AnyView(view))
            controller.view.backgroundColor = .clear
            controller.view.isUserInteractionEnabled = true
            host = controller
            
            addSubview(controller.view)
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                controller.view.topAnchor.constraint(equalTo: topAnchor),
                controller.view.bottomAnchor.constraint(equalTo: bottomAnchor),
                controller.view.leadingAnchor.constraint(equalTo: leadingAnchor),
                controller.view.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        } else {
            host?.rootView = AnyView(view)
        }
        if self.frame.size == .zero {
            self.frame = CGRect(origin: .zero, size: contentSize)
        }
        isUserInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        host?.view.frame = bounds
    }
    
    // 터치 영역 여유
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let extendedBounds = bounds.insetBy(dx: -18, dy: -18)
        return extendedBounds.contains(point)
    }
}

struct MapBounds {
    let southWest: CLLocationCoordinate2D
    let northEast: CLLocationCoordinate2D
    let margin: Double

    var center: CLLocationCoordinate2D {
        .init(
            latitude: (southWest.latitude + northEast.latitude) / 2.0,
            longitude: (southWest.longitude + northEast.longitude) / 2.0
        )
    }

    // 지도에 보여줄 영역 계산
    var region: MKCoordinateRegion {
        let spanLat = abs(northEast.latitude - southWest.latitude) * margin
        let spanLon = abs(northEast.longitude - southWest.longitude) * margin
        return .init(
            center: center,
            span: .init(latitudeDelta: spanLat, longitudeDelta: spanLon)
        )
    }
}

struct ZoneStrokeProvider {
    let zoneStatuses: [ZoneStatus]

    func stroke(for zoneId: Int, isOutline: Bool) -> UIColor {
        if isOutline {
            let checked = StatusManager.shared.userStatus.zoneCheckedStatus[zoneId] == true
            return checked ? UIColor.white.withAlphaComponent(0.85) : UIColor.clear
        } else {
            return ZoneColorResolver.leadingColorOrDefault(
                for: zoneId,
                zoneStatuses: zoneStatuses,
                defaultColor: .primaryGreen
            )
        }
    }
}
