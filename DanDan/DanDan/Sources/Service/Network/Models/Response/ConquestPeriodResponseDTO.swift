//
//  ConquestPeriodResponseDTO.swift
//  DanDan
//
//  Created by Jay on 11/18/25.
//

import Foundation

struct ConquestPeriodResponseDTO: Codable {
    let success: Bool
    let code: String
    let message: String
    let data: CurrentConquestPeriod
}

struct CurrentConquestPeriod: Codable {
    let periodId: String
    let weekIndex: Int
    let startDate: String
    let endDate: String
    let status: String
    let winningTeamId: String?
}
