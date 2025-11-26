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
    
    init(zoneId: Int) {
        self.zoneId = zoneId
        self.teamId = nil
        self.teamName = nil
        self.teamScore = nil
    }

    init(zoneId: Int, teamId: Int?, teamName: String?, teamScore: Int?) {
        self.zoneId = zoneId
        self.teamId = teamId
        self.teamName = teamName
        self.teamScore = teamScore
    }
}
