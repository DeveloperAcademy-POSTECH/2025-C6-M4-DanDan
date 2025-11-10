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
    
    override init() {
        super.init()
        configureLocationManager()
    }
    
    private func configureLocationManager() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.activityType = .fitness
        manager.distanceFilter = 1.0   // 1m 단위로 업데이트 받을 수 있음
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.currentLocation = location
        }
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
