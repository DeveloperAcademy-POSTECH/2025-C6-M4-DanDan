//
//  Gate.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/4/25.
//

import Foundation
import CoreLocation

struct Gate {
    let center: CLLocationCoordinate2D
    let bearingDeg: Double
    let a_perp: Double = 120
    let b_along: Double
    let inScale: Double = 1.0
    let outScale: Double = 1.25
}


