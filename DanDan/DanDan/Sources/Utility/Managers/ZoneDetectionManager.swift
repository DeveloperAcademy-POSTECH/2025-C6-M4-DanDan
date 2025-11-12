import Foundation
import CoreLocation

final class ZoneDetectionManager {
    static let shared = ZoneDetectionManager()
    private init() {}

    func meterOffset(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> (dx: Double, dy: Double) {
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

    func rotateToLocal(dx: Double, dy: Double, bearingDeg: Double) -> (xAlong: Double, yCross: Double) {
        let theta = bearingDeg * .pi / 180.0
        let cosT = cos(theta), sinT = sin(theta)
        let xAlong =  dx * cosT + dy * sinT
        let yCross = -dx * sinT + dy * cosT
        return (xAlong, yCross)
    }

    // Circle-based zone check (use gate.b_along as radius)
    func isInsideCircle(point: CLLocationCoordinate2D, gate: Gate, scale: Double = 1.0) -> Bool {
        let (dx, dy) = meterOffset(from: gate.center, to: point)
        let r = gate.b_along * scale
        let dist2 = dx * dx + dy * dy
        return dist2 <= r * r
    }

    func isInsideEllipse(point: CLLocationCoordinate2D, gate: Gate, scale: Double = 1.0) -> Bool {
        let (dx, dy) = meterOffset(from: gate.center, to: point)
        let (xAlong, yCross) = rotateToLocal(dx: dx, dy: dy, bearingDeg: gate.bearingDeg)
        let a = gate.a_perp * scale
        let b = gate.b_along * scale
        let val = (xAlong * xAlong) / (b * b) + (yCross * yCross) / (a * a)
        return val <= 1.0
    }

    // Convenience for circle in-scale check (hysteresis via inScale / outScale handled by caller)
    func didEnterCircle(point: CLLocationCoordinate2D, gate: Gate) -> Bool {
        return isInsideCircle(point: point, gate: gate, scale: gate.inScale)
    }

    func didEnterGate(point: CLLocationCoordinate2D, gate: Gate) -> Bool {
        return isInsideEllipse(point: point, gate: gate, scale: gate.inScale)
    }

}
