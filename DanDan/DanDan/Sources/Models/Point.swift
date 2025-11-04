//
//  Point.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 10/30/25.
//

import Foundation
import CoreLocation

struct Point: Identifiable, Codable {
    var id: Int { pointId }
    var pointId: Int
    var latitude: Double
    var longitude: Double
    var bearingDeg: Double
    var b_along: Double    
}
