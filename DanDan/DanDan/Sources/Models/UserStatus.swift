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

// MARK: - 더미데이터
extension UserStatus {
    init(
        id: UUID,
        userTeam: String,
        userWeekScore: Int,
        userDailyScore: Int,
        zoneCheckedStatus: [Int: Bool],
        rank: Int
    ) {
        self.id = id
        self.userTeam = userTeam
        self.userWeekScore = userWeekScore
        self.userDailyScore = userDailyScore
        self.zoneCheckedStatus = zoneCheckedStatus
        self.rank = rank
    }
}

extension UserStatus {
    static var dummyStatuses: [UserStatus] {
        return [
            UserStatus(
                id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
                userTeam: "blue",
                userWeekScore: 12,
                userDailyScore: 3,
                zoneCheckedStatus: [:],
                rank: 1
            ),
            UserStatus(
                id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
                userTeam: "blue",
                userWeekScore: 9,
                userDailyScore: 2,
                zoneCheckedStatus: [:],
                rank: 2
            ),
            UserStatus(
                id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
                userTeam: "yellow",
                userWeekScore: 7,
                userDailyScore: 1,
                zoneCheckedStatus: [:],
                rank: 3
            )
        ]
    }
}
