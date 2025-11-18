//
//  Zone.swift
//  DanDan
//
//  Created by Jay on 10/28/25.
//

import Foundation
import SwiftUI
import MapKit

struct ZoneDescriptionInfo {
    let distance: Int
    let description: String
}

struct Zone: Identifiable {
    var id: Int { zoneId }
    var zoneId: Int
    var zoneName: String
    var coordinates: [CLLocationCoordinate2D]
    var zoneColor: UIColor
    
    // 편의 프로퍼티
    var zoneStartPoint: CLLocationCoordinate2D { coordinates.first! }
    var zoneEndPoint: CLLocationCoordinate2D { coordinates.last! }
    
    var description: String {
           zoneDescriptions[zoneId]?.description ?? ""
       }
    
    var distance: Int {
            zoneDescriptions[zoneId]?.distance ?? 0
        }
}

let zones: [Zone] = [
    Zone(
        zoneId: 1,
        zoneName: "상생숲길 1구역",
        coordinates: [
            .init(latitude: 36.002224, longitude: 129.315526),
            .init(latitude: 36.003937, longitude: 129.319718)
        ],
        zoneColor: .A
    ),
    
    Zone(
        zoneId: 2,
        zoneName: "상생숲길 2구역",
        coordinates: [
            .init(latitude: 36.003937, longitude: 129.319718),
            .init(latitude: 36.004956, longitude: 129.322091),
            .init(latitude: 36.005599, longitude: 129.324275)
        ],
        zoneColor: .B
    ),
    
    Zone(
        zoneId: 3,
        zoneName: "상생숲길 3구역",
        coordinates: [
            .init(latitude: 36.005599, longitude: 129.324275),
            .init(latitude: 36.006592, longitude: 129.327412),
            .init(latitude: 36.007522, longitude: 129.330347)
        ],
        zoneColor: .A
    ),
    
    Zone(
        zoneId: 4,
        zoneName: "상생숲길 4구역",
        coordinates: [
            .init(latitude: 36.007522, longitude: 129.330347),
            .init(latitude: 36.008987, longitude: 129.335615)
        ],
        zoneColor: .B
    ),
    
    Zone(
        zoneId: 5,
        zoneName: "어울누리길 구역",
        coordinates: [
            .init(latitude: 36.008987, longitude: 129.335615),
            .init(latitude: 36.009099, longitude: 129.336168),
            .init(latitude: 36.009369, longitude: 129.336805),
            .init(latitude: 36.010414, longitude: 129.338568),
            .init(latitude: 36.011122, longitude: 129.339386),
            .init(latitude: 36.011748, longitude: 129.340135),
            .init(latitude: 36.012024, longitude: 129.340327),
            .init(latitude: 36.013125, longitude: 129.341579)
        ],
        zoneColor: .A
    ),
    
    Zone(
        zoneId: 6,
        zoneName: "활력의 길 1구역",
        coordinates: [
            .init(latitude: 36.013125, longitude: 129.341579),
            .init(latitude: 36.013783, longitude: 129.342378),
            .init(latitude: 36.015621, longitude: 129.344354)
        ],
        zoneColor: .B
    ),
    
    Zone(
        zoneId: 7,
        zoneName: "활력의 길 2구역",
        coordinates: [
            .init(latitude: 36.015621, longitude: 129.344354),
            .init(latitude: 36.016163, longitude: 129.344850),
            .init(latitude: 36.017020, longitude: 129.345767),
            .init(latitude: 36.017763, longitude: 129.346655)
        ],
        zoneColor: .A
    ),
    
    Zone(
        zoneId: 8,
        zoneName: "여유가 있는 띠앗길 1구역",
        coordinates: [
            .init(latitude: 36.017763, longitude: 129.346655),
            .init(latitude: 36.019417, longitude: 129.347979),
            .init(latitude: 36.021819, longitude: 129.349222),
            .init(latitude: 36.023372, longitude: 129.350044)
        ],
        zoneColor: .B
    ),
    
    Zone(
        zoneId: 9,
        zoneName: "여유가 있는 띠앗길 2구역",
        coordinates: [
            .init(latitude: 36.023372, longitude: 129.350044),
            .init(latitude: 36.025780, longitude: 129.351581),
            .init(latitude: 36.027639, longitude: 129.353583),
            .init(latitude: 36.029071, longitude: 129.355408)
        ],
        zoneColor: .A
    ),
    
    Zone(
        zoneId: 10,
        zoneName: "추억의 길 1구역",
        coordinates: [
            .init(latitude: 36.029071, longitude: 129.355408),
            .init(latitude: 36.030591, longitude: 129.356849),
            .init(latitude: 36.033562, longitude: 129.358396),
            .init(latitude: 36.036393, longitude: 129.359417)
        ],
        zoneColor: .B
    ),
    
    Zone(
        zoneId: 11,
        zoneName: "추억의 길 2구역",
        coordinates: [
            .init(latitude: 36.036393, longitude: 129.359417),
            .init(latitude: 36.038895, longitude: 129.361164),
            .init(latitude: 36.041191, longitude: 129.362451)
        ],
        zoneColor: .A
    ),
    
    Zone(
        zoneId: 12,
        zoneName: "숲속 산책길 1구역",
        coordinates: [
            .init(latitude: 36.041191, longitude: 129.362451),
            .init(latitude: 36.043023, longitude: 129.363199),
            .init(latitude: 36.045579, longitude: 129.363669)
        ],
        zoneColor: .B
    ),
    
    Zone(
        zoneId: 13,
        zoneName: "숲속 산책길 2구역",
        coordinates: [
            .init(latitude: 36.045579, longitude: 129.363669),
            .init(latitude: 36.047680, longitude: 129.363945),
            .init(latitude: 36.049023, longitude: 129.363588)
        ],
        zoneColor: .A
    ),
    
    Zone(
        zoneId: 14,
        zoneName: "숲속 산책길 3구역",
        coordinates: [
            .init(latitude: 36.049023, longitude: 129.363588),
            .init(latitude: 36.053573, longitude: 129.361674)
        ],
        zoneColor: .B
    ),
    
    Zone(
        zoneId: 15,
        zoneName: "숲속 산책길 4구역",
        coordinates: [
            .init(latitude: 36.053573, longitude: 129.361674),
            .init(latitude: 36.055094, longitude: 129.361043),
            .init(latitude: 36.057055, longitude: 129.361713),
            .init(latitude: 36.058005, longitude: 129.362256),
            .init(latitude: 36.059291, longitude: 129.362501)
        ],
        zoneColor: .A
    ),
    
    Zone(
        zoneId: 16,
        zoneName: "구역 체크를 위한 임시 구역",
        coordinates: [
            .init(latitude: 36.059291, longitude: 129.362501)
        ],
        zoneColor: .A
    )
]

let zoneDescriptions: [Int: ZoneDescriptionInfo] = [
    1: .init(distance: 420, description: "도심과 가깝고 상가와 인접한 철길숲의 시작 구간"),
    2: .init(distance: 450, description: "주변 차량 도로와 병행하며 개방감이 있는 직선 구간"),
    3: .init(distance: 590, description: "주거 지역과 맞닿아 있는 일상형 산책 구간"),
    4: .init(distance: 500, description: "숲 밀도가 높아지고 그늘이 늘어나는 전환 구간"),
    5: .init(distance: 720, description: "산책로 옆으로 도로·주택가·녹지가 혼재된 복합 생활권 구간"),
    6: .init(distance: 370, description: "경사가 거의 없고 조용한 보행로가 이어지는 구간"),
    7: .init(distance: 320, description: "비교적 직선 길로 이루어진 구간"),
    8: .init(distance: 700, description: "주변이 트여 있고 차량 통행로와 병행된 연결 구간"),
    9: .init(distance: 800, description: "숲과 도로가 교차하며 보행자·자전거 이용량이 많은 구간"),
    10: .init(distance: 900, description: "철길숲 특유의 직선 구간이 길게 이어지는 장거리 구간"),
    11: .init(distance: 600, description: "주변 생활권과 가까우며 산책객이 많은 보행 구간"),
    12: .init(distance: 500, description: "나무가 양옆으로 밀집해 그늘이 많은 구간"),
    13: .init(distance: 390, description: "숲 밀도가 높아 조용한 구간"),
    14: .init(distance: 530, description: "생활권에서 벗어난 자연음이 잘 들리는 구간"),
    15: .init(distance: 670, description: "주변 숲 밀집도와 보행로 폭이 안정적인 구간")
]
