//
//  Point+Gate.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 10/31/25.
//

import CoreLocation

extension Point {
    /// CLLocationCoordinate2D로 변환
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Point로부터 Gate 객체 생성
    func toGate() -> Gate {
        Gate(
            center: coordinate,
            bearingDeg: bearingDeg,
            b_along: b_along
        )
    }
}
