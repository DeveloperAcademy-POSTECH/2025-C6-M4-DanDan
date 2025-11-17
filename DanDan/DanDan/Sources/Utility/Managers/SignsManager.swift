//
//  SignsManager.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/16/25.
//

import Foundation
import MapKit

struct SignTarget {
	let destinationZoneId: Int
	let coordinate: CLLocationCoordinate2D
}

final class SignsManager {
	private weak var mapView: MKMapView?
	private var zones: [Zone]
	private var validRange: ClosedRange<Int>
	private var threshold: CLLocationDistance
	
	private var signAnnotation: SignAnnotation?
	
	init(
		mapView: MKMapView,
		zones: [Zone],
		validRange: ClosedRange<Int> = 1...15,
		threshold: CLLocationDistance = 120
	) {
		self.mapView = mapView
		self.zones = zones
		self.validRange = validRange
		self.threshold = threshold
	}
	
	func update(location: CLLocation, heading: CLLocationDirection) {
		guard let mapView = mapView else { return }
		
		guard let target = decide(location: location, heading: heading) else {
			removeSignIfNeeded()
			return
		}
		
		// 동일 목적지/좌표면 생략
		let boundaryLoc = CLLocation(latitude: target.coordinate.latitude, longitude: target.coordinate.longitude)
		if let existing = signAnnotation {
			let sameDest = existing.destinationZoneId == target.destinationZoneId
			let existingLoc = CLLocation(latitude: existing.coordinate.latitude, longitude: existing.coordinate.longitude)
			if sameDest && existingLoc.distance(from: boundaryLoc) < 5 {
				return
			}
			mapView.removeAnnotation(existing)
			signAnnotation = nil
		}
		
		let ann = SignAnnotation(coordinate: target.coordinate, destinationZoneId: target.destinationZoneId)
		signAnnotation = ann
		mapView.addAnnotation(ann)
	}
	
	// MARK: - Pure-ish decision
	func decide(location: CLLocation, heading: CLLocationDirection) -> SignTarget? {
		let mainZones = zones.filter { validRange.contains($0.zoneId) }
		guard let nearest = mainZones.min(by: { dist(location.coordinate, centroid(of: $0.coordinates)) < dist(location.coordinate, centroid(of: $1.coordinates)) }) else {
			return nil
		}
		
		let zoneBearing = bearingDeg(from: nearest.zoneStartPoint, to: nearest.zoneEndPoint)
		let diff = deltaDeg(heading, zoneBearing)
		let isForward = diff <= 90
		
		let destinationZoneId = isForward ? (nearest.zoneId + 1) : (nearest.zoneId - 1)
		guard validRange.contains(destinationZoneId) else { return nil }
		
		let boundaryCoord = isForward ? nearest.zoneEndPoint : nearest.zoneStartPoint
		let boundaryLoc = CLLocation(latitude: boundaryCoord.latitude, longitude: boundaryCoord.longitude)
		let distanceToBoundary = location.distance(from: boundaryLoc)
		
		guard distanceToBoundary <= threshold else { return nil }
		
		return SignTarget(destinationZoneId: destinationZoneId, coordinate: boundaryCoord)
	}
	
	private func removeSignIfNeeded() {
		if let existing = signAnnotation {
			mapView?.removeAnnotation(existing)
			signAnnotation = nil
		}
	}
	
	// MARK: - Helpers
	private func centroid(of coords: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
		guard !coords.isEmpty else { return .init(latitude: 0, longitude: 0) }
		let lat = coords.map(\.latitude).reduce(0, +) / Double(coords.count)
		let lon = coords.map(\.longitude).reduce(0, +) / Double(coords.count)
		return .init(latitude: lat, longitude: lon)
	}
	
	private func dist(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) -> CLLocationDistance {
		CLLocation(latitude: a.latitude, longitude: a.longitude).distance(from: CLLocation(latitude: b.latitude, longitude: b.longitude))
	}
	
	private func bearingDeg(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
		let φ1 = from.latitude * .pi / 180
		let φ2 = to.latitude * .pi / 180
		let Δλ = (to.longitude - from.longitude) * .pi / 180
		
		let y = sin(Δλ) * cos(φ2)
		let x = cos(φ1) * sin(φ2) - sin(φ1) * cos(φ2) * cos(Δλ)
		var θ = atan2(y, x) * 180 / .pi
		if θ < 0 { θ += 360 }
		return θ
	}
	
	private func deltaDeg(_ a: CLLocationDirection, _ b: CLLocationDirection) -> Double {
		let na = normalizeDeg(a)
		let nb = normalizeDeg(b)
		let d = abs(na - nb)
		return d > 180 ? 360 - d : d
	}
	
	private func normalizeDeg(_ x: CLLocationDirection) -> Double {
		var v = x.truncatingRemainder(dividingBy: 360)
		if v < 0 { v += 360 }
		return v
	}
}


