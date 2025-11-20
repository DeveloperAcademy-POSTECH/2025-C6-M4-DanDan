//
//  ZoneStatusDetailResponseDTO.swift
//  DanDan
//
//  Created by Jay on 11/20/25.
//

import Foundation

struct ZoneStatusDetailResponseDTO: Codable {
    let success: Bool
    let code: String
    let message: String
    let data: [ZoneStatusDetail]
    let errors: [String]?
    let meta: MetaData
}

struct ZoneStatusDetail: Codable, Identifiable {
    var id: Int { zoneId }

    let zoneId: Int
    let zoneName: String
    let leadingTeamId: String?
    let leadingTeamName: String?
    let teamScores: [ZoneStatusDetailTeamScore]
}

struct ZoneStatusDetailTeamScore: Codable {
    let teamId: String
    let teamName: String
    let totalScore: Int
}
