//
//  ZoneTracker.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 10/30/25.
//

import CoreLocation
import Foundation

/// ZoneTracker는 사용자의 위치를 기반으로 각 Zone의 시작/종료 게이트 통과와 전진 거리를 판단하여
/// 완료 여부를 **UserStatus.zoneCheckedStatus[zoneId]** 로 관리합니다.
final class ZoneTracker {
    struct Runtime {
        var entryIsStart: Bool? = nil           // 첫 진입이 시작 게이트인지 종료 게이트인지
        var startedAlongRef: Double? = nil      // 진입 시점의 진행 위치(x 축 기준)
    }

    private(set) var currentIndex: Int?         // 현재 진행 중인 zones 배열 인덱스
    private var rt = Runtime()
    private let minForwardMeters: Double = 10   // 완료로 인정할 최소 전진 거리
    private var prevLocation: CLLocationCoordinate2D? // 이전 위치(전이 판단용)
    private let switchAlignThreshold: Double = 0.2   // 정렬도 개선 임계값 (cos 기준)
    private let switchDistThresholdMeters: Double = 20 // 거리 개선 임계값 (m)

    var zones: [Zone]                            // 설계된 Zone 모델: { zoneId, zoneStartPoint, zoneEndPoint, ... }
    var userStatus: UserStatus                   // 설계된 UserStatus 모델: 완료 여부는 zoneCheckedStatus에 저장

    init(zones: [Zone], userStatus: UserStatus) {
        self.zones = zones
        self.userStatus = userStatus
    }

    /// 두 좌표로부터 진행 방향(bearing, deg)을 계산
    private func computeBearingDeg(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let (dx, dy) = meterOffset(from: from, to: to)
        // atan2(y, x): 북=+y, 동=+x, rotateToLocal에서 along 계산과 일치하도록 사용
        let rad = atan2(dy, dx)
        var deg = rad * 180.0 / .pi
        if deg < 0 { deg += 360 }
        return deg
    }

    private enum GateHit { case start, end, none }

    private func whichGateHit(point: CLLocationCoordinate2D, start: Gate, end: Gate) -> GateHit {
        if didEnterGate(point: point, gate: start) { return .start }
        if didEnterGate(point: point, gate: end) { return .end }
        return .none
    }

    /// 바깥→안쪽으로의 전이(enter) 여부 판단
    private func didEnterGateTransition(prev: CLLocationCoordinate2D?, current: CLLocationCoordinate2D, gate: Gate) -> Bool {
        guard let prev = prev else { return false }
        let wasInside = isInsideEllipse(point: prev, gate: gate, scale: gate.inScale)
        let isInsideNow = isInsideEllipse(point: current, gate: gate, scale: gate.inScale)
        return (wasInside == false) && (isInsideNow == true)
    }

    /// 안쪽→바깥으로의 전이(exit) 여부 판단
    private func didExitGateTransition(prev: CLLocationCoordinate2D?, current: CLLocationCoordinate2D, gate: Gate) -> Bool {
        guard let prev = prev else { return false }
        let wasInside = isInsideEllipse(point: prev, gate: gate, scale: gate.outScale)
        let isInsideNow = isInsideEllipse(point: current, gate: gate, scale: gate.outScale)
        return (wasInside == true) && (isInsideNow == false)
    }

    /// 현재 위치를 받아 구간 진행을 처리합니다.
    /// - 모든 구간이 완료되었으면 조기 종료
    /// - 진행 중인 구간이 없으면 다음 미완료 구간에서 시작 시도
    /// - 진행 중이면 진행 상황 갱신
    func process(location: CLLocation) {
        if allZonesCompleted { return }

        if currentIndex == nil {
            // 전이(enter 또는 exit)가 발생한 구역만 후보로 선정
            // 동률일 때는 사용자 이동 방향과 구역 bearing의 정렬도를 우선
            var candidates: [(idx: Int, entryIsStart: Bool, distance: CLLocationDistance, align: Double)] = []
            let moveBearing: Double? = {
                guard let prev = prevLocation else { return nil }
                return computeBearingDeg(from: prev, to: location.coordinate)
            }()
            for (i, z) in zones.enumerated() {
                let bearing = computeBearingDeg(from: z.zoneStartPoint, to: z.zoneEndPoint)
                let startGate = Gate(center: z.zoneStartPoint, bearingDeg: bearing, b_along: 50)
                let endGate = Gate(center: z.zoneEndPoint, bearingDeg: bearing, b_along: 50)
                // 안→밖 전이(시작 트리거 케이스 1)
                if didExitGateTransition(prev: prevLocation, current: location.coordinate, gate: startGate) {
                    let d = CLLocation(latitude: startGate.center.latitude, longitude: startGate.center.longitude).distance(from: location)
                    let align = moveBearing.map { cos((($0 - bearing) * .pi / 180.0)) } ?? 0
                    candidates.append((idx: i, entryIsStart: true, distance: d, align: align))
                }
                if didExitGateTransition(prev: prevLocation, current: location.coordinate, gate: endGate) {
                    let d = CLLocation(latitude: endGate.center.latitude, longitude: endGate.center.longitude).distance(from: location)
                    let align = moveBearing.map { cos((($0 - bearing) * .pi / 180.0)) } ?? 0
                    candidates.append((idx: i, entryIsStart: false, distance: d, align: align))
                }
                // 밖→안 전이(시작 트리거 케이스 2)
                if didEnterGateTransition(prev: prevLocation, current: location.coordinate, gate: startGate) {
                    let d = CLLocation(latitude: startGate.center.latitude, longitude: startGate.center.longitude).distance(from: location)
                    let align = moveBearing.map { cos((($0 - bearing) * .pi / 180.0)) } ?? 0
                    candidates.append((idx: i, entryIsStart: true, distance: d, align: align))
                }
                if didEnterGateTransition(prev: prevLocation, current: location.coordinate, gate: endGate) {
                    let d = CLLocation(latitude: endGate.center.latitude, longitude: endGate.center.longitude).distance(from: location)
                    let align = moveBearing.map { cos((($0 - bearing) * .pi / 180.0)) } ?? 0
                    candidates.append((idx: i, entryIsStart: false, distance: d, align: align))
                }
            }
            if let best = candidates.sorted(by: { (l, r) in
                if l.align == r.align { return l.distance < r.distance }
                return l.align > r.align
            }).first {
                currentIndex = best.idx
                rt.entryIsStart = best.entryIsStart
                let z = zones[best.idx]
                let bearing = computeBearingDeg(from: z.zoneStartPoint, to: z.zoneEndPoint)
                let entryGate = best.entryIsStart ? Gate(center: z.zoneStartPoint, bearingDeg: bearing, b_along: 50)
                                                  : Gate(center: z.zoneEndPoint,   bearingDeg: bearing, b_along: 50)
                let (dx, dy) = meterOffset(from: entryGate.center, to: location.coordinate)
                let (xAlong, _) = rotateToLocal(dx: dx, dy: dy, bearingDeg: entryGate.bearingDeg)
                rt.startedAlongRef = xAlong
            } else {
                // 전이가 없으면: (초기 prevLocation != nil) 현재 게이트 내부라면 보조 시작 로직 적용
                if prevLocation != nil {
                    var inside: [(idx: Int, entryIsStart: Bool, distance: CLLocationDistance, align: Double)] = []
                    for (i, z) in zones.enumerated() {
                        let bearing = computeBearingDeg(from: z.zoneStartPoint, to: z.zoneEndPoint)
                        let startGate = Gate(center: z.zoneStartPoint, bearingDeg: bearing, b_along: 50)
                        let endGate = Gate(center: z.zoneEndPoint, bearingDeg: bearing, b_along: 50)
                        let hitS = didEnterGate(point: location.coordinate, gate: startGate)
                        let hitE = didEnterGate(point: location.coordinate, gate: endGate)
                        if hitS || hitE {
                            let dS = CLLocation(latitude: startGate.center.latitude, longitude: startGate.center.longitude).distance(from: location)
                            let dE = CLLocation(latitude: endGate.center.latitude, longitude: endGate.center.longitude).distance(from: location)
                            let (entryIsStart, d) = (dS <= dE) ? (true, dS) : (false, dE)
                            let align = moveBearing.map { cos((($0 - bearing) * .pi / 180.0)) } ?? 0
                            inside.append((idx: i, entryIsStart: entryIsStart, distance: d, align: align))
                        }
                    }
                    if let best = inside.sorted(by: { (l, r) in
                        if l.align == r.align { return l.distance < r.distance }
                        return l.align > r.align
                    }).first {
                        currentIndex = best.idx
                        rt.entryIsStart = best.entryIsStart
                        let z = zones[best.idx]
                        let bearing = computeBearingDeg(from: z.zoneStartPoint, to: z.zoneEndPoint)
                        let entryGate = best.entryIsStart ? Gate(center: z.zoneStartPoint, bearingDeg: bearing, b_along: 50)
                                                          : Gate(center: z.zoneEndPoint,   bearingDeg: bearing, b_along: 50)
                        let (dx, dy) = meterOffset(from: entryGate.center, to: location.coordinate)
                        let (xAlong, _) = rotateToLocal(dx: dx, dy: dy, bearingDeg: entryGate.bearingDeg)
                        rt.startedAlongRef = xAlong
                    } else {
                        prevLocation = location.coordinate
                        return
                    }
                } else {
                    // 초기 프레임: 즉시 시작하지 않음
                    prevLocation = location.coordinate
                    return
                }
            }
        } else if let idx = currentIndex {
            // 게이트 밖에서도 측정을 계속 유지하되,
            // 다른 구역에서 전이가 발생했고 현재 구역의 두 게이트(outScale) 모두 바깥이면 그 구역으로 스위칭
            let zCur = zones[idx]
            let curBearing = computeBearingDeg(from: zCur.zoneStartPoint, to: zCur.zoneEndPoint)
            let curStart = Gate(center: zCur.zoneStartPoint, bearingDeg: curBearing, b_along: 50)
            let curEnd   = Gate(center: zCur.zoneEndPoint,   bearingDeg: curBearing, b_along: 50)
            let nearCurStart = isInsideEllipse(point: location.coordinate, gate: curStart, scale: curStart.outScale)
            let nearCurEnd   = isInsideEllipse(point: location.coordinate, gate: curEnd,   scale: curEnd.outScale)

            var switchCandidates: [(idx: Int, entryIsStart: Bool, dCandMin: CLLocationDistance, align: Double)] = []
            let moveBearing: Double? = {
                guard let prev = prevLocation else { return nil }
                return computeBearingDeg(from: prev, to: location.coordinate)
            }()
            for (i, z) in zones.enumerated() {
                if i == idx { continue }
                let b = computeBearingDeg(from: z.zoneStartPoint, to: z.zoneEndPoint)
                let sGate = Gate(center: z.zoneStartPoint, bearingDeg: b, b_along: 50)
                let eGate = Gate(center: z.zoneEndPoint,   bearingDeg: b, b_along: 50)
                var fired: [(Bool, CLLocationDistance, Double)] = [] // (entryIsStart, dCandMin, align)
                let dS = CLLocation(latitude: sGate.center.latitude, longitude: sGate.center.longitude).distance(from: location)
                let dE = CLLocation(latitude: eGate.center.latitude, longitude: eGate.center.longitude).distance(from: location)
                let dMin = min(dS, dE)
                if didEnterGateTransition(prev: prevLocation, current: location.coordinate, gate: sGate) {
                    let a = moveBearing.map { cos((($0 - b) * .pi / 180.0)) } ?? 0
                    fired.append((true, dMin, a))
                }
                if didEnterGateTransition(prev: prevLocation, current: location.coordinate, gate: eGate) {
                    let a = moveBearing.map { cos((($0 - b) * .pi / 180.0)) } ?? 0
                    fired.append((false, dMin, a))
                }
                if let best = fired.sorted(by: { (l, r) in
                    if l.2 == r.2 { return l.1 < r.1 }
                    return l.2 > r.2
                }).first {
                    switchCandidates.append((idx: i, entryIsStart: best.0, dCandMin: best.1, align: best.2))
                }
            }

            if !(nearCurStart || nearCurEnd) {
                // 현재 구역 기준 정렬도/거리 산출
                let alignCurr = moveBearing.map { cos((($0 - curBearing) * .pi / 180.0)) } ?? 0
                let dCurStart = CLLocation(latitude: curStart.center.latitude, longitude: curStart.center.longitude).distance(from: location)
                let dCurEnd   = CLLocation(latitude: curEnd.center.latitude,   longitude: curEnd.center.longitude).distance(from: location)
                let dCurrMin = min(dCurStart, dCurEnd)

                // 임계 통과하는 후보만 선별 (보수적: AND 조건)
                let qualified: [(idx: Int, entryIsStart: Bool, alignImp: Double, distImp: Double)] = switchCandidates.compactMap { cand in
                    let alignImp = cand.align - alignCurr
                    let distImp = dCurrMin - cand.dCandMin
                    guard alignImp >= switchAlignThreshold && distImp >= switchDistThresholdMeters else { return nil }
                    return (idx: cand.idx, entryIsStart: cand.entryIsStart, alignImp: alignImp, distImp: distImp)
                }

                if let best = qualified.sorted(by: { (l, r) in
                    if l.alignImp == r.alignImp { return l.distImp > r.distImp }
                    return l.alignImp > r.alignImp
                }).first {
                    // 스위칭
                    currentIndex = best.idx
                    rt.entryIsStart = best.entryIsStart
                    let z = zones[best.idx]
                    let bearing = computeBearingDeg(from: z.zoneStartPoint, to: z.zoneEndPoint)
                    let entryGate = best.entryIsStart ? Gate(center: z.zoneStartPoint, bearingDeg: bearing, b_along: 50)
                                                      : Gate(center: z.zoneEndPoint,   bearingDeg: bearing, b_along: 50)
                    let (dx, dy) = meterOffset(from: entryGate.center, to: location.coordinate)
                    let (xAlong, _) = rotateToLocal(dx: dx, dy: dy, bearingDeg: entryGate.bearingDeg)
                    rt.startedAlongRef = xAlong
                }
            }

            // 진행 업데이트(완료 판정 전용)
            updateProgress(idx: idx, at: location)
        }

        // 다음 업데이트에서 전이 판단을 위해 현재 위치 저장
        prevLocation = location.coordinate
    }

    /// 다음 미완료 Zone 의 배열 인덱스를 반환
    private func nextIncompleteZoneIndex() -> Int? {
        zones.firstIndex { z in
            userStatus.zoneCheckedStatus[z.zoneId] != true
        }
    }

    /// 모든 Zone 이 완료되었는지 여부
    private var allZonesCompleted: Bool {
        zones.allSatisfy { z in userStatus.zoneCheckedStatus[z.zoneId] == true }
    }

    /// 지정된 구간 인덱스(idx)에서 진입 시도를 수행합니다.
    private func tryStartIfNeeded(idx: Int, at loc: CLLocation) {
        let z = zones[idx]
        let bearing = computeBearingDeg(from: z.zoneStartPoint, to: z.zoneEndPoint)
        let startGate = Gate(center: z.zoneStartPoint, bearingDeg: bearing, b_along: 50)
        let endGate = Gate(center: z.zoneEndPoint, bearingDeg: bearing, b_along: 50)

        switch whichGateHit(point: loc.coordinate, start: startGate, end: endGate) {
        case .start, .end:
            currentIndex = idx

            // 진입한 게이트가 시작인지 종료인지 기록
            let entryIsStart = (whichGateHit(point: loc.coordinate, start: startGate, end: endGate) == .start)
            rt.entryIsStart = entryIsStart

            // 진입 게이트 기준 진행 위치(x)를 저장
            let gate = entryIsStart ? startGate : endGate
            let (dx, dy) = meterOffset(from: gate.center, to: loc.coordinate)
            let (xAlong, _) = rotateToLocal(dx: dx, dy: dy, bearingDeg: gate.bearingDeg)
            rt.startedAlongRef = xAlong

        case .none:
            break
        }
    }

    /// 현재 진행 중인 구간(idx)의 진행 상황을 갱신합니다.
    private func updateProgress(idx: Int, at loc: CLLocation) {
        guard let entryIsStart = rt.entryIsStart, let started = rt.startedAlongRef else { return }

        let z = zones[idx]
        let bearing = computeBearingDeg(from: z.zoneStartPoint, to: z.zoneEndPoint)
        let startGate = Gate(center: z.zoneStartPoint, bearingDeg: bearing, b_along: 50)
        let endGate = Gate(center: z.zoneEndPoint, bearingDeg: bearing, b_along: 50)

        // 진입/반대 게이트 결정
        let entryGate = entryIsStart ? startGate : endGate
        let exitGate  = entryIsStart ? endGate  : startGate

        // 진입 게이트 좌표계 기준 진행 거리 계산
        let (dx, dy) = meterOffset(from: entryGate.center, to: loc.coordinate)
        let (xAlong, _) = rotateToLocal(dx: dx, dy: dy, bearingDeg: entryGate.bearingDeg)
        let forward = abs(xAlong - started)

        // 반대 게이트를 '통과(밖→안)' + 최소 전진 거리 확보 시 완료 처리
        if didEnterGateTransition(prev: prevLocation, current: loc.coordinate, gate: exitGate), forward >= minForwardMeters {
            userStatus.zoneCheckedStatus[z.zoneId] = true

            // 상태 초기화 (다음 구역 시작은 전이 발생 시점에 맡김)
            currentIndex = nil
            rt = Runtime()
        }
    }

}
