//
//  UserStatus.swift
//  DanDan
//
//  Created by Jay on 10/28/25.
//

import Foundation

struct UserStatus: Identifiable, Codable {
    var id: UUID
    var userTeam: String
    var userWeekScore: Int
    var userDailyScore: Int
    var zoneCheckedStatus: [Int: Bool]
    var rank: Int

    init() {
        self.id = UUID()
        self.userTeam = ""
        self.userWeekScore = 0
        self.userDailyScore = 0
        self.zoneCheckedStatus = [:]
        self.rank = 0
    }
    
    /// 기존 유저의 ID를 유지하면서 상태를 초기화할 때 사용합니다.
    /// - Parameter old: 이전 유저 상태
    init(from old: UserStatus) {
        self.id = old.id
        self.userTeam = ""
        self.userWeekScore = 0
        self.userDailyScore = 0
        self.zoneCheckedStatus = [:]
        self.rank = 0
    }
}

extension UserStatus {
    init(userDailyScore: Int) {
        self.id = UUID()
        self.userTeam = ""
        self.userWeekScore = 0
        self.userDailyScore = userDailyScore
        self.zoneCheckedStatus = [:]
        self.rank = 0
    }
}
