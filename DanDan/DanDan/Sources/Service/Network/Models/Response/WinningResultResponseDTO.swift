//
//  WinningResultResponseDTO.swift
//  DanDan
//
//  Created by Jay on 11/10/25.
//

import Foundation

struct WinningResultResponse: Codable {
    let success: Bool
    let code: String
    let message: String
    let data: WinningResultData
    let errors: [String]
    let meta: MetaData
}

struct WinningResultData: Codable {
    let winningTeam: WinningTeam
    let topContributors: [Contributor]
}

struct WinningTeam: Codable {
    let teamName: String
    let teamColor: String
    let conqueredZones: Int
}

struct Contributor: Codable, Identifiable {
    var id: UUID { UUID() } // 식별용
    let profileUrl: String?
    let rankInTeam: Int
}
