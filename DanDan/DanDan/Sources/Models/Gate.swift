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
    let a_perp: Double = 80
    let b_along: Double
    let inScale: Double = 0.9
    let outScale: Double = 1.1
}


