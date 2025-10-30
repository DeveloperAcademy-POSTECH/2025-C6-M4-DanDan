//
//  ZoneDetectionManager.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 10/30/25.
//

import Foundation
import CoreLocation

/// 타원 게이트 정의
/// - bearingDeg: 구간 진행방향 θ (deg)
/// - a_perp: 장축(횡방향) 반경 [m] (고정값 100m)
/// - b_along: 단축(진행방향) 반경 [m]
/// - inScale/outScale: 히스테리시스 스케일 (입장/퇴장 문턱)
struct Gate {
    let center: CLLocationCoordinate2D // 기준 좌표가 되는 부분
    let bearingDeg: Double       // 구간 진행방향 θ
    let a_perp: Double = 100     // 장축: 횡방향 반경 (meters) — 고정값 100m
    let b_along: Double          // 단축: 진행방향 반경 (meters)
    let inScale: Double = 0.9    // IN 문턱(작게) → 더 안쪽까지 들어와야 인정
    let outScale: Double = 1.1   // OUT 문턱(크게) → 조금 흔들려도 유지
}

/// 위경도 간 동/북 방향 오프셋(미터)
func meterOffset(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> (dx: Double, dy: Double) {
    // equirectangular 근사 (소구역 가정) — East=dx, North=dy (meters)
    let lat1 = from.latitude * .pi/180
    let lon1 = from.longitude * .pi/180
    let lat2 = to.latitude   * .pi/180
    let lon2 = to.longitude  * .pi/180
    let r: Double = 6378137.0
    let dLat = lat2 - lat1
    let dLon = lon2 - lon1
    let x = dLon * cos((lat1 + lat2)/2) * r
    let y = dLat * r
    return (dx: x, dy: y)
}

/// 전역 좌표(dx, dy in meters)를 산책로 기준 로컬 좌표로 회전
/// - Returns: (xAlong: 진행방향 성분, yCross: 횡방향 성분) [meters]
func rotateToLocal(dx: Double, dy: Double, bearingDeg: Double) -> (xAlong: Double, yCross: Double) {
    let theta = bearingDeg * .pi / 180.0
    let cosT = cos(theta), sinT = sin(theta)
    let xAlong =  dx * cosT + dy * sinT      // along (종방향)
    let yCross = -dx * sinT + dy * cosT      // cross (횡방향)
    return (xAlong, yCross)
}

/// 스케일이 적용된(히스테리시스 포함) 타원 내부 판정
/// - scale = 1.0 : 기본 타원
/// - scale = inScale(0.9) : 더 작은 타원 → IN 문턱
/// - scale = outScale(1.1): 더 큰  타원 → OUT 문턱
func isInsideEllipse(point: CLLocationCoordinate2D, gate: Gate, scale: Double = 1.0) -> Bool {
    // 1) 위경도 -> 평면 미터 좌표
    let (dx, dy) = meterOffset(from: gate.center, to: point)  // East, North
    // 2) 로컬 회전 좌표 (xAlong, yCross)
    let (xAlong, yCross) = rotateToLocal(dx: dx, dy: dy, bearingDeg: gate.bearingDeg)
    // 3) 단축(b_along) = 진행방향, 장축(a_perp) = 횡방향
    let a = gate.a_perp * scale
    let b = gate.b_along * scale
    let val = (xAlong * xAlong) / (b * b) + (yCross * yCross) / (a * a)
    return val <= 1.0
}

/// 히스테리시스가 적용된 게이트 입장(enter) / 퇴장(exit) 판정
/// - enter: IN 문턱(작은 타원) 기준으로 내부인지
/// - exit:  OUT 문턱(큰  타원) 기준으로 외부인지
func didEnterGate(point: CLLocationCoordinate2D, gate: Gate) -> Bool {
    return isInsideEllipse(point: point, gate: gate, scale: gate.inScale)
}

func didExitGate(point: CLLocationCoordinate2D, gate: Gate) -> Bool {
    return !isInsideEllipse(point: point, gate: gate, scale: gate.outScale)
}
