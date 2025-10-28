//
//  UserStatus.swift
//  DanDan
//
//  Created by Jay on 10/28/25.
//

import Foundation

struct UserStatus: Identifiable, Codable {
    var id: UUID
    var userName: String
    var userTeam: String
    var userWeekScore: Int
    var userDailyScore: Int
    var isZoneChecked: Bool
    var Rank: Int
}
