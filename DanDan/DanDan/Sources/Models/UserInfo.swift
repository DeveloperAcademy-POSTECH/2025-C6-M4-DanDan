//
//  User.swift
//  DanDan
//
//  Created by Jay on 10/28/25.
//

import Foundation

struct UserInfo: Identifiable, Codable {
    var id: UUID
    var userName: String
    var userTeam: String
    var userVictoryCnt: Int
    var userTotalScore: Int
    var userImage: [Data]
    var rankHistory: [RankRecord]
}
