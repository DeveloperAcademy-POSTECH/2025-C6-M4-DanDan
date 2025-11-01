//
//  Zone.swift
//  DanDan
//
//  Created by Jay on 10/28/25.
//

import Foundation
import SwiftUI
import MapKit

struct Zone: Identifiable {
    var id: Int { zoneId }
    var zoneId: Int
    var zoneName: String
    var coordinates: [CLLocationCoordinate2D]
    var zoneColor: UIColor
    
    // 편의 프로퍼티
    var zoneStartPoint: CLLocationCoordinate2D { coordinates.first! }
    var zoneEndPoint: CLLocationCoordinate2D { coordinates.last! }
}

let zones: [Zone] = [
    Zone(
        zoneId: 1,
        zoneName: "상생숲길 1구역",
        coordinates: [
            .init(latitude: 36.002224, longitude: 129.315526),
            .init(latitude: 36.003937, longitude: 129.319718)
        ],
        zoneColor: .blue
    ),
    Zone(
        zoneId: 2,
        zoneName: "상생숲길 2구역",
        coordinates: [
            .init(latitude: 36.003937, longitude: 129.319718),
            .init(latitude: 36.005599, longitude: 129.324275)
        ],
        zoneColor: .white
    ),
    Zone(
        zoneId: 3,
        zoneName: "상생숲길 3구역",
        coordinates: [
            .init(latitude: 36.005599, longitude: 129.324275),
            .init(latitude: 36.007522, longitude: 129.330347)
        ],
        zoneColor: .blue
    ),
    Zone(
        zoneId: 4,
        zoneName: "상생숲길 4구역",
        coordinates: [
            .init(latitude: 36.007522, longitude: 129.330347),
            .init(latitude: 36.008987, longitude: 129.335615)
        ],
        zoneColor: .white
    ),
    Zone(
        zoneId: 5,
        zoneName: "어울누리길 구역",
        coordinates: [
            .init(latitude: 36.008987, longitude: 129.335615),
            .init(latitude: 36.013125, longitude: 129.341579)
        ],
        zoneColor: .blue
    ),
    Zone(
        zoneId: 6,
        zoneName: "활력의 길 1구역",
        coordinates: [
            .init(latitude: 36.013125, longitude: 129.341579),
            .init(latitude: 36.015621, longitude: 129.344354)
        ],
        zoneColor: .white
    ),
    Zone(
        zoneId: 7,
        zoneName: "활력의 길 2구역",
        coordinates: [
            .init(latitude: 36.015621, longitude: 129.344354),
            .init(latitude: 36.017763, longitude: 129.346655)
        ],
        zoneColor: .blue
    ),
    Zone(
        zoneId: 8,
        zoneName: "여유가 있는 띠앗길 1구역",
        coordinates: [
            .init(latitude: 36.017763, longitude: 129.346655),
            .init(latitude: 36.023372, longitude: 129.350044)
        ],
        zoneColor: .white
    ),
    Zone(
        zoneId: 9,
        zoneName: "여유가 있는 띠앗길 2구역",
        coordinates: [
            .init(latitude: 36.023372, longitude: 129.350044),
            .init(latitude: 36.029071, longitude: 129.355408)
        ],
        zoneColor: .blue
    ),
    Zone(
        zoneId: 10,
        zoneName: "추억의길 1구역",
        coordinates: [
            .init(latitude: 36.029071, longitude: 129.355408),
            .init(latitude: 36.036393, longitude: 129.359417)
        ],
        zoneColor: .white
    ),
    Zone(
        zoneId: 11,
        zoneName: "추억의길 2구역",
        coordinates: [
            .init(latitude: 36.036393, longitude: 129.359417),
            .init(latitude: 36.041191, longitude: 129.362451)
        ],
        zoneColor: .blue
    ),
    Zone(
        zoneId: 12,
        zoneName: "숲속 산책길 1구역",
        coordinates: [
            .init(latitude: 36.041191, longitude: 129.362451),
            .init(latitude: 36.045579, longitude: 129.363669)
        ],
        zoneColor: .white
    ),
    Zone(
        zoneId: 13,
        zoneName: "숲속 산책길 2구역",
        coordinates: [
            .init(latitude: 36.045579, longitude: 129.363669),
            .init(latitude: 36.049023, longitude: 129.363588)
        ],
        zoneColor: .blue
    ),
    Zone(
        zoneId: 14,
        zoneName: "숲속 산책길 3구역",
        coordinates: [
            .init(latitude: 36.049023, longitude: 129.363588),
            .init(latitude: 36.053573, longitude: 129.361674)
        ],
        zoneColor: .white
    ),
    Zone(
        zoneId: 15,
        zoneName: "숲속 산책길 4구역",
        coordinates: [
            .init(latitude: 36.053573, longitude: 129.361674),
            .init(latitude: 36.059291, longitude: 129.362501)
        ],
        zoneColor: .blue
    )
]
