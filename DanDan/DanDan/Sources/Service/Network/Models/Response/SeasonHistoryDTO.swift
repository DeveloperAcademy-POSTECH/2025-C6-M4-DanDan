//
//  SeasonHistoryDTO.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/8/25.
//

import Foundation

/// 시즌 히스토리 API 응답 루트
struct SeasonHistoryAPIResponse: Decodable {
    let success: Bool
    let code: String
    let message: String
    let data: SeasonHistoryDataDTO
}

/// 시즌 히스토리 데이터 컨테이너
struct SeasonHistoryDataDTO: Decodable {
    let currentWeek: CurrentWeekDTO?
    let pastWeeks: PastWeeksPageDTO
}

/// 과거 주차 히스토리 페이지네이션 컨테이너
struct PastWeeksPageDTO: Decodable {
    let data: [PastWeekDTO]
    let total: Int
    let page: Int
    let limit: Int
    let totalPages: Int
    let hasNext: Bool
    let hasPrev: Bool
}

/// 현재 진행 중인 주차 정보
struct CurrentWeekDTO: Decodable {
    let userWeekScore: Int
    let ranking: Int
    let weekIndex: Int
    let startDate: String
    let endDate: String
    let userTeam: String
    let totalDistanceKm: Double?

    private enum CodingKeys: String, CodingKey {
        case userWeekScore
        case ranking
        case weekIndex
        case startDate
        case endDate
        case userTeam
        case totalDistanceKm
    }
}

/// 과거 주차 히스토리 아이템 (최신순 정렬)
struct PastWeekDTO: Decodable {
    let weekScore: Int
    let rank: Int
    let weekIndex: Int
    let teamAtPeriod: String
    let startDate: String?
    let endDate: String?
    let distanceKm: Double?
}



