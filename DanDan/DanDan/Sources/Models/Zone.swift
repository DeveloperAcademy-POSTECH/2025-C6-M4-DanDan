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
    
    var description: String {
        zoneDescriptions[zoneId] ?? ""
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

let zoneDescriptions: [Int: String] = [
    1: "420m — 도심과 가까워 보행량이 많고 상가와 인접한 철길숲의 시작 구간",
    2: "450m — 주변 차량 도로와 병행하며 개방감이 있는 직선 위주의 산책 구간",
    3: "590m — 주거 지역과 맞닿아 있어 생활 소음이 들리는 일상형 산책 구간",
    4: "500m — 도심을 벗어나며 숲 밀도가 높아지고 그늘이 늘어나는 전환 구간",
    5: "720m — 산책로 옆으로 도로·주택가·녹지가 혼재된 복합 생활권 구간",
    6: "370m — 경사가 거의 없고 조용한 보행로가 이어지는 안정적인 이동 구간",
    7: "320m — 비교적 직선 길로 이루어져 이동 속도가 일정하게 유지되는 구간",
    8: "700m — 주변이 트여 있고 차량 통행로와 병행되어 개방감이 큰 연결 구간",
    9: "800m — 숲과 도로가 교차하며 보행자·자전거 이용량이 모두 많은 혼합 구간",
    10: "900m — 철길숲 특유의 직선 구간이 길게 이어지는 장거리 이동 코스",
    11: "600m — 주변 생활권과 가까우며 산책객이 많은 보행 중심 구간",
    12: "500m — 나무가 양옆으로 밀집해 그늘이 많고 온도 변화가 적은 숲형 구간",
    13: "390m — 숲 밀도가 높아 조용하며 차량 소음이 적은 안정적인 보행 구간",
    14: "530m — 생활권에서 벗어나 비교적 고요하고 자연음이 잘 들리는 산책 구간",
    15: "670m — 주변 숲 밀집도와 보행로 폭이 안정적이며 마무리 동선에 적합한 구간"
]
