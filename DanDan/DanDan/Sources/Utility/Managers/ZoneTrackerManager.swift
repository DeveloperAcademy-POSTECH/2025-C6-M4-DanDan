//
//  ZoneTrackerManager.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 10/30/25.
//

import CoreLocation
import Foundation

final class ZoneTrackerManager {
    private func post(_ name: Notification.Name, _ info: [String: Any]) {
        var payload = info
        payload[ZoneDebugEvents.Key.timestamp] = Date()
        NotificationCenter.default.post(name: name, object: nil, userInfo: payload)
    }
    
    struct Runtime {
        var entryIsStart: Bool? = nil
        var startedAlongRef: Double? = nil
    }

    private(set) var currentIndex: Int?
    private var rt = Runtime()
    private let minForwardMeters: Double = 10
    private var prevLocation: CLLocationCoordinate2D?
    private let switchAlignThreshold: Double = 0.2
    private let switchDistThresholdMeters: Double = 20

    var zones: [Zone]
    var userStatus: UserStatus

    init(zones: [Zone], userStatus: UserStatus) {
        self.zones = zones
        self.userStatus = userStatus
    }

    private func computeBearingDeg(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let (dx, dy) = ZoneDetectionManager.shared.meterOffset(from: from, to: to)
        let rad = atan2(dy, dx)
        var deg = rad * 180.0 / .pi
        if deg < 0 { deg += 360 }
        return deg
    }

    private func didEnterGateTransition(prev: CLLocationCoordinate2D?, current: CLLocationCoordinate2D, gate: Gate) -> Bool {
        guard let prev = prev else { return false }
        let wasInside = ZoneDetectionManager.shared.isInsideCircle(point: prev, gate: gate, scale: gate.inScale)
        let isInsideNow = ZoneDetectionManager.shared.isInsideCircle(point: current, gate: gate, scale: gate.inScale)
        return (wasInside == false) && (isInsideNow == true)
    }

    private func didExitGateTransition(prev: CLLocationCoordinate2D?, current: CLLocationCoordinate2D, gate: Gate) -> Bool {
        guard let prev = prev else { return false }
        let wasInside = ZoneDetectionManager.shared.isInsideCircle(point: prev, gate: gate, scale: gate.outScale)
        let isInsideNow = ZoneDetectionManager.shared.isInsideCircle(point: current, gate: gate, scale: gate.outScale)
        return (wasInside == true) && (isInsideNow == false)
    }

    func process(location: CLLocation) {
        if allZonesCompleted { return }

        if currentIndex == nil {
            var candidates: [(idx: Int, entryIsStart: Bool, distance: CLLocationDistance, align: Double)] = []
            let moveBearing: Double? = {
                guard let prev = prevLocation else { return nil }
                return computeBearingDeg(from: prev, to: location.coordinate)
            }()
            for (i, z) in zones.enumerated() {
                let bearing = computeBearingDeg(from: z.zoneStartPoint, to: z.zoneEndPoint)
                let startGate = Gate(center: z.zoneStartPoint, bearingDeg: bearing, b_along: 50)
                let endGate   = Gate(center: z.zoneEndPoint,   bearingDeg: bearing, b_along: 50)
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
                let (dx, dy) = ZoneDetectionManager.shared.meterOffset(from: entryGate.center, to: location.coordinate)
                let (xAlong, _) = ZoneDetectionManager.shared.rotateToLocal(dx: dx, dy: dy, bearingDeg: entryGate.bearingDeg)
                rt.startedAlongRef = xAlong
                
                post(ZoneDebugEvents.currentIndexChanged, [
                    ZoneDebugEvents.Key.zoneIndex: best.idx,
                    ZoneDebugEvents.Key.entryIsStart: best.entryIsStart
                ])
            } else {
                if prevLocation != nil {
                    var inside: [(idx: Int, entryIsStart: Bool, distance: CLLocationDistance, align: Double)] = []
                    for (i, z) in zones.enumerated() {
                        let bearing = computeBearingDeg(from: z.zoneStartPoint, to: z.zoneEndPoint)
                        let startGate = Gate(center: z.zoneStartPoint, bearingDeg: bearing, b_along: 50)
                        let endGate   = Gate(center: z.zoneEndPoint,   bearingDeg: bearing, b_along: 50)
                        let hitS = ZoneDetectionManager.shared.didEnterCircle(point: location.coordinate, gate: startGate)
                        let hitE = ZoneDetectionManager.shared.didEnterCircle(point: location.coordinate, gate: endGate)
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
                        let (dx, dy) = ZoneDetectionManager.shared.meterOffset(from: entryGate.center, to: location.coordinate)
                        let (xAlong, _) = ZoneDetectionManager.shared.rotateToLocal(dx: dx, dy: dy, bearingDeg: entryGate.bearingDeg)
                        rt.startedAlongRef = xAlong
                        
                        post(ZoneDebugEvents.currentIndexChanged, [
                            ZoneDebugEvents.Key.zoneIndex: best.idx,
                            ZoneDebugEvents.Key.entryIsStart: best.entryIsStart
                        ])
                    } else {
                        prevLocation = location.coordinate
                        return
                    }
                } else {
                    prevLocation = location.coordinate
                    return
                }
            }
        } else if let idx = currentIndex {
            let zCur = zones[idx]
            let curBearing = computeBearingDeg(from: zCur.zoneStartPoint, to: zCur.zoneEndPoint)
            let curStart = Gate(center: zCur.zoneStartPoint, bearingDeg: curBearing, b_along: 50)
            let curEnd   = Gate(center: zCur.zoneEndPoint,   bearingDeg: curBearing, b_along: 50)
            let nearCurStart = ZoneDetectionManager.shared.isInsideCircle(point: location.coordinate, gate: curStart, scale: curStart.outScale)
            let nearCurEnd   = ZoneDetectionManager.shared.isInsideCircle(point: location.coordinate, gate: curEnd,   scale: curEnd.outScale)

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
                var fired: [(Bool, CLLocationDistance, Double)] = []
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
                let alignCurr = moveBearing.map { cos((($0 - curBearing) * .pi / 180.0)) } ?? 0
                let dCurStart = CLLocation(latitude: curStart.center.latitude, longitude: curStart.center.longitude).distance(from: location)
                let dCurEnd   = CLLocation(latitude: curEnd.center.latitude,   longitude: curEnd.center.longitude).distance(from: location)
                let dCurrMin = min(dCurStart, dCurEnd)

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
                    currentIndex = best.idx
                    rt.entryIsStart = best.entryIsStart
                    let z = zones[best.idx]
                    let bearing = computeBearingDeg(from: z.zoneStartPoint, to: z.zoneEndPoint)
                    let entryGate = best.entryIsStart ? Gate(center: z.zoneStartPoint, bearingDeg: bearing, b_along: 50)
                                                  : Gate(center: z.zoneEndPoint,   bearingDeg: bearing, b_along: 50)
                    let (dx, dy) = ZoneDetectionManager.shared.meterOffset(from: entryGate.center, to: location.coordinate)
                    let (xAlong, _) = ZoneDetectionManager.shared.rotateToLocal(dx: dx, dy: dy, bearingDeg: entryGate.bearingDeg)
                    rt.startedAlongRef = xAlong
                    
                    post(ZoneDebugEvents.currentIndexChanged, [
                        ZoneDebugEvents.Key.zoneIndex: best.idx,
                        ZoneDebugEvents.Key.entryIsStart: best.entryIsStart,
                        ZoneDebugEvents.Key.switchedFromIndex: idx
                    ])
                }
            }

            updateProgress(idx: idx, at: location)
        }

        prevLocation = location.coordinate
    }

    private var allZonesCompleted: Bool {
        zones.allSatisfy { z in userStatus.zoneCheckedStatus[z.zoneId] == true }
    }

    private func updateProgress(idx: Int, at loc: CLLocation) {
        guard let entryIsStart = rt.entryIsStart, let started = rt.startedAlongRef else { return }

        let z = zones[idx]
        let bearing = computeBearingDeg(from: z.zoneStartPoint, to: z.zoneEndPoint)
        let startGate = Gate(center: z.zoneStartPoint, bearingDeg: bearing, b_along: 50)
        let endGate   = Gate(center: z.zoneEndPoint,   bearingDeg: bearing, b_along: 50)

        let entryGate = entryIsStart ? startGate : endGate
        let exitGate  = entryIsStart ? endGate  : startGate

        let (dx, dy) = ZoneDetectionManager.shared.meterOffset(from: entryGate.center, to: loc.coordinate)
        let (xAlong, _) = ZoneDetectionManager.shared.rotateToLocal(dx: dx, dy: dy, bearingDeg: entryGate.bearingDeg)
        let forward = abs(xAlong - started)

        let exitHit = didEnterGateTransition(prev: prevLocation, current: loc.coordinate, gate: exitGate)
        
        post(ZoneDebugEvents.progressUpdated, [
            ZoneDebugEvents.Key.zoneIndex: idx,
            ZoneDebugEvents.Key.entryIsStart: entryIsStart,
            ZoneDebugEvents.Key.forwardMeters: forward,
            ZoneDebugEvents.Key.minForwardMeters: minForwardMeters,
            ZoneDebugEvents.Key.exitEntered: exitHit,
            ZoneDebugEvents.Key.location: loc
        ])
        
        if exitHit, forward >= minForwardMeters {
            userStatus.zoneCheckedStatus[z.zoneId] = true
            post(ZoneDebugEvents.zoneCompleted, [
                ZoneDebugEvents.Key.zoneId: z.zoneId
            ])
            currentIndex = nil
            rt = Runtime()
        }
    }
}
