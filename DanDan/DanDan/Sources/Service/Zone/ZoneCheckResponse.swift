//
//  ZoneCheckResponse.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/7/25.
//

import Foundation

/// 오늘 완료된 구역 조회 응답 래퍼
struct ZoneCheckResponse: Decodable {
    let success: Bool?
    let code: String?
    let message: String?
    let data: DailyCheckData?
    let errors: [String]?
}

/// 응답 본문
struct DailyCheckData: Decodable {
    let zones: [DailyCheckZone]
}

/// 완료된 구역 항목
struct DailyCheckZone: Decodable {
    let zoneId: Int
    let isCompleted: Bool

    private enum CodingKeys: String, CodingKey {
        case zoneId = "zone_id"
        case isCompleted = "is_completed"
    }
}


