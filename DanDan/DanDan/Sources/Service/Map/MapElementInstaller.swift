//
//  MapElementInstaller.swift
//  DanDan
//
//  Created by soyeonsoo on 11/9/25.
//

import MapKit
import SwiftUI

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
