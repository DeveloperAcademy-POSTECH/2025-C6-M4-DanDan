//
//  RankingManager.swift
//  DanDan
//
//  Created by Jay on 10/29/25.
//

import Foundation

class RankingManager {
    static let shared = RankingManager()

    /// 사용자 기여 점수를 기반으로 순위를 계산하고 정렬된 배열을 반환합니다.
    /// 동점자는 동일한 순위를 부여 받습니다.
    ///  - Parameter users: 정렬 대상 사용자 배열
    ///  - Returns: 순위가 반영된 정렬된 사용자 배열
    func assignRanking(to users: [UserStatus]) -> [UserStatus] {
        let sorted = users.sorted { $0.userWeekScore > $1.userWeekScore }

        var rankedUsers: [UserStatus] = []
        var currentRank = 1
        var previousScore: Int? = nil

        for (index, user) in sorted.enumerated() {
            var updatedUser = user

            if let prev = previousScore {
                if user.userWeekScore != prev {
                    currentRank = index + 1
                }
            }

            updatedUser.rank = currentRank
            rankedUsers.append(updatedUser)
            previousScore = user.userWeekScore
        }

        return rankedUsers
    }
}
