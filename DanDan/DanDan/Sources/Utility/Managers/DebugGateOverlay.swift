//
//  DebugGateOverlay.swift
//  DanDan
//
//  Created by Assistant on 11/11/25.
//
//  디버그 빌드에서 구역 판정 원(게이트)을 시각화하기 위한 유틸리티
//

import Foundation
import MapKit

enum DebugGateOverlay {
    /// 모든 구역의 시작/종료 게이트 원(내/외부)을 MKCircle로 생성
    static func makeCircles(for zones: [Zone]) -> [MKCircle] {
        var overlays: [MKCircle] = []
        for z in zones {
            let bearing = computeBearingDeg(from: z.zoneStartPoint, to: z.zoneEndPoint)
            let startGate = Gate(center: z.zoneStartPoint, bearingDeg: bearing, b_along: 20)
            let endGate   = Gate(center: z.zoneEndPoint,   bearingDeg: bearing, b_along: 20)
            
            // Start gate - inner/outer
            overlays.append(makeCircle(center: startGate.center,
                                       radius: startGate.b_along * startGate.inScale,
                                       title: "debug-circle-start-in"))
            overlays.append(makeCircle(center: startGate.center,
                                       radius: startGate.b_along * startGate.outScale,
                                       title: "debug-circle-start-out"))
            // End gate - inner/outer
            overlays.append(makeCircle(center: endGate.center,
                                       radius: endGate.b_along * endGate.inScale,
                                       title: "debug-circle-end-in"))
            overlays.append(makeCircle(center: endGate.center,
                                       radius: endGate.b_along * endGate.outScale,
                                       title: "debug-circle-end-out"))
        }
        return overlays
    }
    
    /// 게이트를 '선(폴리라인)'으로 생성
    /// - 중복 제거: 각 구역의 '시작' 선만 추가
    /// - 시작/끝 숨김: 첫 구역의 시작선, 마지막 구역의 끝선은 추가하지 않음
    static func makeGateLines(for zones: [Zone]) -> [MKPolyline] {
        var lines: [MKPolyline] = []
        for (idx, z) in zones.enumerated() {
            let bearing = computeBearingDeg(from: z.zoneStartPoint, to: z.zoneEndPoint)
            let startGate = Gate(center: z.zoneStartPoint, bearingDeg: bearing, b_along: 20)
            
            // 중복 방지: '시작' 선만 추가, 단 첫 구역(idx == 0)은 생략하여 시작선 숨김
            if idx > 0 {
                lines.append(makeGateLine(center: startGate.center,
                                          aPerp: startGate.a_perp,
                                          bearingDeg: bearing,
                                          title: "debug-gate-start"))
            }
            // '끝' 선은 추가하지 않음 → 마지막 구역의 끝선도 자연스럽게 숨김
        }
        return lines
    }
    
    private static func computeBearingDeg(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let lat1 = from.latitude * .pi/180
        let lon1 = from.longitude * .pi/180
        let lat2 = to.latitude   * .pi/180
        let lon2 = to.longitude  * .pi/180
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        var brng = atan2(y, x) * 180.0 / .pi
        if brng < 0 { brng += 360 }
        return brng
    }
    
    /// 원형 오버레이 생성
    private static func makeCircle(center: CLLocationCoordinate2D, radius: CLLocationDistance, title: String) -> MKCircle {
        let c = MKCircle(center: center, radius: radius)
        c.title = title
        return c
    }
    
    /// 진행방향에 수직인 게이트 선분 생성
    private static func makeGateLine(center: CLLocationCoordinate2D, aPerp: Double, bearingDeg: Double, title: String) -> MKPolyline {
        // 수직 각도 = bearing + 90°
        let perp1 = bearingDeg + 90.0
        let perp2 = bearingDeg - 90.0
        let p1 = offsetCoordinate(from: center, distanceMeters: aPerp, bearingDeg: perp1)
        let p2 = offsetCoordinate(from: center, distanceMeters: aPerp, bearingDeg: perp2)
        var coords = [p1, p2]
        let line = MKPolyline(coordinates: &coords, count: coords.count)
        line.title = title
        return line
    }
    
    /// 거리/방위로 좌표 이동
    private static func offsetCoordinate(from: CLLocationCoordinate2D, distanceMeters: CLLocationDistance, bearingDeg: Double) -> CLLocationCoordinate2D {
        let R = 6_378_137.0 // WGS84
        let brng = bearingDeg * .pi / 180.0
        let lat1 = from.latitude * .pi / 180.0
        let lon1 = from.longitude * .pi / 180.0
        let dr = distanceMeters / R
        
        let lat2 = asin(sin(lat1) * cos(dr) + cos(lat1) * sin(dr) * cos(brng))
        let lon2 = lon1 + atan2(sin(brng) * sin(dr) * cos(lat1),
                                cos(dr) - sin(lat1) * sin(lat2))
        return .init(latitude: lat2 * 180.0 / .pi,
                     longitude: lon2 * 180.0 / .pi)
    }
}


