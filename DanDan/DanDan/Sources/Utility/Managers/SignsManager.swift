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
	
	private var signAnnotations: [SignAnnotation] = []
	private var installedAllSigns = false
	
	init(
		mapView: MKMapView,
		zones: [Zone],
		validRange: ClosedRange<Int> = 1...15,
		threshold: CLLocationDistance = 200
	) {
		self.mapView = mapView
		self.zones = zones
		self.validRange = validRange
		self.threshold = threshold
	}
	
	func update(location: CLLocation, heading: CLLocationDirection) {
		ensureAllSignsInstalled()
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
		
		// 유효 범위를 벗어나면 클램프하여 항상 목적지 결정
		let rawNextId = isForward ? (nearest.zoneId + 1) : (nearest.zoneId - 1)
		let clampedNextId = min(max(rawNextId, validRange.lowerBound), validRange.upperBound)
		
		// 진행 방향에 맞는 경계 좌표 사용
		let boundaryCoord = isForward ? nearest.zoneEndPoint : nearest.zoneStartPoint
		
		return SignTarget(destinationZoneId: clampedNextId, coordinate: boundaryCoord)
	}
	
	private func removeSignIfNeeded() {
		guard !signAnnotations.isEmpty else { return }
		if let mapView = mapView {
			mapView.removeAnnotations(signAnnotations)
		}
		signAnnotations.removeAll()
		installedAllSigns = false
	}
	
	/// 지도에 모든 경계 표지판을 한 번만 설치
	private func ensureAllSignsInstalled() {
		guard let mapView = mapView, !installedAllSigns else { return }
		
		// zoneId로 빠르게 찾기 위한 딕셔너리
		let zoneById: [Int: Zone] = Dictionary(uniqueKeysWithValues: zones.map { ($0.zoneId, $0) })
		var anns: [SignAnnotation] = []
		
		// 각 경계( id -> id+1 )에 대해 표지판 하나씩 설치
		let lower = validRange.lowerBound
		let upper = validRange.upperBound
		if lower < upper {
			for id in lower..<(upper) {
				guard let z = zoneById[id] else { continue }
				let coord = z.zoneEndPoint
				let ann = SignAnnotation(coordinate: coord, destinationZoneId: id + 1)
				anns.append(ann)
			}
		}
		
		guard !anns.isEmpty else { return }
		signAnnotations = anns
		mapView.addAnnotations(anns)
		installedAllSigns = true
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


