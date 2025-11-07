//
//  MainMapInfoResponseDTO.swift
//  DanDan
//
//  Created by Jay on 11/7/25.
//

import Foundation

// MARK: - 전체 응답
struct MainMapInfoResponseDTO: Codable {
    let success: Bool
    let code: String
    let message: String
    let data: MainMapInfoData
    let errors: [String]
    let meta: MetaData
}

// MARK: - Data
struct MainMapInfoData: Codable {
    let teams: [MainMapTeam]
    let userDailyScore: Int
    let startDate: String
    let endDate: String
}

// MARK: - 팀 정보
struct MainMapTeam: Codable {
    let teamName: String
    let conqueredZones: Int
}
