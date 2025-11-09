//
//  ColoredPolyline.swift
//  DanDan
//
//  Created by soyeonsoo on 11/9/25.
//

import MapKit

final class ColoredPolyline: MKPolyline {
    var color: UIColor = .white
    var isOutline: Bool = false
    var zoneId: Int = 0
}
