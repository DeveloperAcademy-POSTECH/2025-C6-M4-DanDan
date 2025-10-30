//
//  ZoneScoreManager.swift
//  DanDan
//
//  Created by Jay on 10/30/25.
//

import Foundation

class ZoneScoreManager: ObservableObject {
    static let shared = ZoneScoreManager()

    @Published var zoneScores: [ZoneScore] = []

    /// 모든 구간의 점수를 초기화합니다.
    func resetZoneScore() {
        zoneScores = zoneScores.map { ZoneScore(zoneId: $0.zoneId) }
    }
}
