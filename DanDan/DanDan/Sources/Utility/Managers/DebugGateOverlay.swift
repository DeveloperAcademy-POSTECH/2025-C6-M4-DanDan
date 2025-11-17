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

#if DEBUG
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
}
#endif


