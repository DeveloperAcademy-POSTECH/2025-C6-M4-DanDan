//
//  ZoneConquestStatus.swift
//  DanDan
//
//  Created by Jay on 10/26/25.
//

struct ZoneConquestStatus: Identifiable {
    var id: Int { zoneId }
    var zoneId: Int
    var teamId: Int?
    var teamName: String?
    var teamScore: Int?
}
