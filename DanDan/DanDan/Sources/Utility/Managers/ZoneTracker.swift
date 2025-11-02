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
    private let minForwardMeters: Double = 20   // 완료로 인정할 최소 전진 거리

    var zones: [Zone]                            // 설계된 Zone 모델: { zoneId, zoneStartPoint, zoneEndPoint, ... }
    var userStatus: UserStatus                   // 설계된 UserStatus 모델: 완료 여부는 zoneCheckedStatus에 저장

    init(zones: [Zone], userStatus: UserStatus) {
        self.zones = zones
        self.userStatus = userStatus
    }

    /// pointId 로부터 Gate 를 생성 (실제 구현은 Gate 생성 로직에 맞게 사용)
    private func makeGate(from pointId: Int) -> Gate {
        let params = gateParams(for: pointId) // (center: CLLocationCoordinate2D, bearingDeg: Double, b_along: Double)
        return Gate(center: params.center, bearingDeg: params.bearingDeg, b_along: params.b_along)
    }

    /// 좌표로부터 Gate 생성 (임시 기본값 사용)
    private func makeGate(from coordinate: CLLocationCoordinate2D) -> Gate {
        Gate(center: coordinate, bearingDeg: 0.0, b_along: 0.0)
    }

    /// 임시 게이트 파라미터 반환 함수 (실제 구현 전용 더미 데이터)
    private func gateParams(for pointId: Int) -> (center: CLLocationCoordinate2D, bearingDeg: Double, b_along: Double) {
        // TODO: 실제 게이트 좌표 매핑 로직으로 교체 필요
        // 현재는 pointId에 따라 약간 다른 좌표를 반환하는 임시 데이터
        let baseLat = 36.02
        let baseLon = 129.36
        let offset = Double(pointId) * 0.0001
        return (
            center: CLLocationCoordinate2D(latitude: baseLat + offset, longitude: baseLon + offset),
            bearingDeg: 0.0,
            b_along: 0.0
        )
    }

    private enum GateHit { case start, end, none }

    private func whichGateHit(point: CLLocationCoordinate2D, start: Gate, end: Gate) -> GateHit {
        if didEnterGate(point: point, gate: start) { return .start }
        if didEnterGate(point: point, gate: end) { return .end }
        return .none
    }

    /// 현재 위치를 받아 구간 진행을 처리합니다.
    /// - 모든 구간이 완료되었으면 조기 종료
    /// - 진행 중인 구간이 없으면 다음 미완료 구간에서 시작 시도
    /// - 진행 중이면 진행 상황 갱신
    func process(location: CLLocation) {
        if allZonesCompleted { return }

        if currentIndex == nil {
            guard let idx = nextIncompleteZoneIndex() else { return }
            tryStartIfNeeded(idx: idx, at: location)
        } else if let idx = currentIndex {
            updateProgress(idx: idx, at: location)
        }
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
        let startGate = makeGate(from: z.zoneStartPoint)
        let endGate = makeGate(from: z.zoneEndPoint)

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
        let startGate = makeGate(from: z.zoneStartPoint)
        let endGate = makeGate(from: z.zoneEndPoint)

        // 진입/반대 게이트 결정
        let entryGate = entryIsStart ? startGate : endGate
        let exitGate  = entryIsStart ? endGate  : startGate

        // 진입 게이트 좌표계 기준 진행 거리 계산
        let (dx, dy) = meterOffset(from: entryGate.center, to: loc.coordinate)
        let (xAlong, _) = rotateToLocal(dx: dx, dy: dy, bearingDeg: entryGate.bearingDeg)
        let forward = abs(xAlong - started)

        // 반대 게이트 통과 + 최소 전진 거리 확보 시 완료 처리
        if didEnterGate(point: loc.coordinate, gate: exitGate), forward >= minForwardMeters {
            userStatus.zoneCheckedStatus[z.zoneId] = true

            // 다음 미완료 구간으로 넘어가기 위해 상태 초기화 후 재시도
            currentIndex = nil
            rt = Runtime()

            if let next = nextIncompleteZoneIndex() {
                tryStartIfNeeded(idx: next, at: loc)
            }
        }
    }
}
