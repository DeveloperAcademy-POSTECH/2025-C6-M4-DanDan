//
//  Point.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 10/30/25.
//

import Foundation
import CoreLocation

/// Point 모델은 산책로 상의 게이트/체크포인트를 나타냅니다.
/// 각 Point는 구간(Zone)의 시작점 또는 종료점으로 사용됩니다.
struct Point: Identifiable, Codable {
    var id: Int { pointId }
    var pointId: Int
    var latitude: Double
    var longitude: Double
    var bearingDeg: Double  // 구간 진행 방향 (도)
    var b_along: Double     // 게이트의 진행방향 반경 (미터)
}
