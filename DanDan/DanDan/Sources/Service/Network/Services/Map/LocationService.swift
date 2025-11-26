//
//  LocationService.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 10/29/25.
//

import Foundation
import CoreLocation
import Combine

final class LocationService: NSObject, ObservableObject {
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private let manager = CLLocationManager()
    private var lastChecked: [Int: Bool] = [:]
    private var tracker: ZoneTrackerManager = .init(zones: zones, userStatus: StatusManager.shared.userStatus)
    
    override init() {
        super.init()
        configureLocationManager()
    }
    
    private func configureLocationManager() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.activityType = .fitness
        manager.distanceFilter = 10.0   // 절전: 10m 단위로 업데이트
        manager.pausesLocationUpdatesAutomatically = true
        manager.allowsBackgroundLocationUpdates = true
        manager.showsBackgroundLocationIndicator = true
        manager.requestWhenInUseAuthorization()
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch authorizationStatus {
        case .authorizedAlways:
            manager.startUpdatingLocation()
        case .authorizedWhenInUse:
            manager.requestAlwaysAuthorization()
            manager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.currentLocation = location
        }
        
        // Precise(정밀) 위치 임시 요청: 사용자가 대략적 위치만 허용한 경우
        if #available(iOS 14.0, *) {
            if manager.accuracyAuthorization == .reducedAccuracy {
                manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "ZoneEntryHighAccuracy", completion: nil)
            }
        }
        
        // 구역 판별 및 완료 처리 (중앙 파이프라인)
        tracker.process(location: location)
        let current = tracker.userStatus.zoneCheckedStatus
        var newlyCompleted: [Int] = []
        for (zoneId, isChecked) in current where isChecked == true {
            if lastChecked[zoneId] != true {
                StatusManager.shared.setZoneChecked(zoneId: zoneId, checked: true)
                newlyCompleted.append(zoneId)
            }
        }
        lastChecked = current
        
        for zoneId in newlyCompleted {
            OfflineZoneCompletionQueue.shared.enqueue(zoneId: zoneId)
        }
        OfflineZoneCompletionQueue.shared.processQueueIfPossible()
    }
    
    // 위치 실패 시 콘솔에 에러 출력
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                print("❌ 위치 권한이 거부됨")
            case .locationUnknown:
                print("❌ 현재 위치를 알 수 없음 (GPS 신호 약함)")
            default:
                print("❌ 알 수 없는 위치 오류: \(clError.localizedDescription)")
            }
        } else {
            print("📍 위치 업데이트 실패:", error.localizedDescription)
        }
    }
}
