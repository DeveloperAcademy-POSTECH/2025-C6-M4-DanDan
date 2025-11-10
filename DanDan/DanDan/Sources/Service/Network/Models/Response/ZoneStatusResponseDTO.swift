//
//  ZoneStatusResponseDTO.swift
//  DanDan
//
//  Created by Jay on 11/8/25.
//

import Foundation

// MARK: - Zone Status Response DTO
struct ZoneStatusResponseDTO: Codable {
    let data: [ZoneStatus]
    let errors: [String]
    let meta: MetaData
}

// MARK: - Zone Status
struct ZoneStatus: Codable, Identifiable {
    var id: Int { zoneId } 
    let zoneId: Int
    let leadingTeamName: String?

    enum CodingKeys: String, CodingKey {
        case zoneId = "zoneId"
        case leadingTeamName
    }
}

