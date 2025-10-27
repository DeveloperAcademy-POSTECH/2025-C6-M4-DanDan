//
//  ZoneConquestStatus.swift
//  DanDan
//
//  Created by Jay on 10/26/25.
//

struct ZoneConquestStatus: Identifiable {
    var id: Int { zoneId }
    let zoneId: Int
    let teamId: Int?
    let teamName: String?
    let isConquered: Bool
}
