//
//  RegionMonitoringManager.swift
//  DanDan
//
//  Created by Assistant on 11/11/25.
//

import Foundation
import CoreLocation

final class RegionMonitoringManager: NSObject {
    static let shared = RegionMonitoringManager()
    
    private let manager = CLLocationManager()
    private var stopTimer: Timer?
    
    private override init() {
        super.init()
        manager.delegate = self
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = true
        manager.requestAlwaysAuthorization()
    }
    
    func startMonitoringZones(zones: [Zone], radius: CLLocationDistance = 100.0) {
        // 정리
        for region in manager.monitoredRegions {
            manager.stopMonitoring(for: region)
        }
        // 최대 20개 제약
        let limited = Array(zones.prefix(20))
        for z in limited {
            let c = centroid(of: z.coordinates)
            let region = CLCircularRegion(center: c, radius: radius, identifier: "zone_\(z.zoneId)")
            region.notifyOnEntry = true
            region.notifyOnExit = true
            manager.startMonitoring(for: region)
        }
    }
    
    private func centroid(of coords: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        guard !coords.isEmpty else { return CLLocationCoordinate2D(latitude: 0, longitude: 0) }
        let lat = coords.map { $0.latitude }.reduce(0, +) / Double(coords.count)
        let lon = coords.map { $0.longitude }.reduce(0, +) / Double(coords.count)
        return .init(latitude: lat, longitude: lon)
    }
    
    private func burstLocationUpdatesBriefly() {
        manager.startUpdatingLocation()
        stopTimer?.invalidate()
        stopTimer = Timer.scheduledTimer(withTimeInterval: 12, repeats: false) { [weak self] _ in
            self?.manager.stopUpdatingLocation()
        }
    }
}

extension RegionMonitoringManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        burstLocationUpdatesBriefly()
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        burstLocationUpdatesBriefly()
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("⚠️ Region monitoring failed:", region?.identifier ?? "-", error.localizedDescription)
    }
}


