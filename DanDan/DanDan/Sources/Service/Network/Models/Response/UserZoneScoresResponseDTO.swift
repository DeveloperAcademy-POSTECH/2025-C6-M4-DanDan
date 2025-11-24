//
//  UserZoneScoresResponseDTO.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/24/25.
//

import Foundation

struct UserZoneScoresAPIResponse: Decodable {
    let success: Bool
    let code: String
    let message: String
    let data: UserZoneScoresDataDTO
    let errors: [String]?
    let meta: MetaData?
}

struct UserZoneScoresDataDTO: Decodable {
    let zoneScores: [UserZoneScoreItemDTO]
}

struct UserZoneScoreItemDTO: Decodable {
    let zoneId: Int
    let totalScore: Int
}


