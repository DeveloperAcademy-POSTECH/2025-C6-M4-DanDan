//
//  MyRankingResponseDTO.swift
//  DanDan
//
//  Created by Jay on 11/15/25.
//

import SwiftUI

// MARK: - Team Ranking Response DTO
struct MyRankingResponseDTO: Codable {
    let success: Bool
    let code: String
    let message: String
    let data: MyRankingData
    let errors: [String]
    let meta: MetaData
}

// MARK: - Data
struct MyRankingData: Codable {
    let periodId: String
    let userId: String
    let userName: String
    let profileUrl: String?
    let totalScore: Int
    let rankInTeam: Int
    let rankOverall: Int
    let teamId: String
    let teamName: String
    let teamColor: String
}
