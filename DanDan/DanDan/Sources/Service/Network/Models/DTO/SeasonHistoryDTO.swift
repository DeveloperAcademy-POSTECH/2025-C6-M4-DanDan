//
//  SeasonHistoryDTO.swift
//  DanDan
//
//  Created by Assistant on 11/7/25.
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
    let pastWeeks: [PastWeekDTO]
    // 서버가 페이지 네이션 메타를 내려줄 수 있으니 확장 여지를 남김
    let hasNext: Bool?
    let page: Int?
    let size: Int?
}

/// 현재 진행 중인 주차 정보
struct CurrentWeekDTO: Decodable {
    let userWeekScore: Int
    let ranking: Int
    let weekIndex: Int
    let startDate: String
    let endDate: String
    let userTeam: String
    let distanceKm: Double? // 추후 서버 연동 시 사용
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

// MARK: - Date Parsing Helper

enum SeasonHistoryDateParser {
    /// 서버 날짜 문자열을 Date로 파싱 (여러 포맷 지원)
    static func parse(_ value: String) -> Date? {
        // 1) ISO8601 우선
        if let iso = ISO8601DateFormatter().date(from: value) {
            return iso
        }
        // 2) yyyy-MM-dd
        let fmts = [
            "yyyy-MM-dd",
            "yyyy.MM.dd",
            "yyyy-MM-dd'T'HH:mm:ssXXXXX",
            "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        ]
        for f in fmts {
            let df = DateFormatter()
            df.locale = Locale(identifier: "ko_KR")
            df.timeZone = TimeZone(identifier: "Asia/Seoul")
            df.dateFormat = f
            if let d = df.date(from: value) {
                return d
            }
        }
        return nil
    }
}


