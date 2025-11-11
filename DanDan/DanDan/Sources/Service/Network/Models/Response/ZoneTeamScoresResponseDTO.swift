//
//  ZoneTeamScoresResponseDTO.swift
//  DanDan
//
//  Created by soyeonsoo on 11/10/25.
//

import Foundation

struct ZoneTeamScoresResponseDTO: Codable {
    let success: Bool
    let code: String
    let message: String
    let data: ZoneTeamScoresData
    let errors: [String]
    let meta: MetaData
}

struct ZoneTeamScoresData: Codable {
    let zoneId: Int
    let zoneName: String
    let distanceKm: String
    let leadingTeamId: String?
    let leadingTeamName: String?
    let teamScores: [ZoneTeamScoreDTO]
}

struct ZoneTeamScoreDTO: Codable {
    let teamId: String
    let teamName: String
    let totalScore: Int
}
