//
//  ZoneScore.swift
//  DanDan
//
//  Created by Jay on 10/26/25.
//

import Foundation

struct ZoneScore: Identifiable, Codable {
    var id: Int { zoneId }
    var zoneId: Int
    var teamId: Int
    var teamName: String
    var teamScore: Int
    
    init(zoneId: Int) {
        self.zoneId = zoneId
        self.teamId = 0
        self.teamName = ""
        self.teamScore = 0
    }
}
