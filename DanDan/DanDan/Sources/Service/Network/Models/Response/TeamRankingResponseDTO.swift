//
//  TeamRankingResponseDTO.swift
//  DanDan
//
//  Created by Jay on 11/6/25.
//

import Foundation

// MARK: - Team Ranking Response DTO
struct TeamRankingResponseDTO: Codable {
    let success: Bool
    let code: String
    let message: String
    let data: TeamRankingData
    let errors: [String]
    let meta: MetaData
}

// MARK: - Data
struct TeamRankingData: Codable {
    let periodId: String
    let rankings: [TeamRanking]
}

// MARK: - Ranking
struct TeamRanking: Codable, Identifiable {
    let id: UUID
    let teamName: String
    let teamColor: String
    let conqueredZones: Int
    let rank: Int

    enum CodingKeys: String, CodingKey {
        case id = "teamId"
        case teamName, teamColor, conqueredZones, rank
    }
}
