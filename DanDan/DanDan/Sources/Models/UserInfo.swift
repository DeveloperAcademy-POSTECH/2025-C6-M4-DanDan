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
    var userVictoryCnt: Int
    var userTotalScore: Int
    var userImage: [Data]
    var rankHistory: [RankRecord]
}

// MARK: - 더미데이터
extension UserInfo {
    static var dummyUsers: [UserInfo] {
        return [
            UserInfo(
                id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
                userName: "소연수",
                userVictoryCnt: 2,
                userTotalScore: 34,
                userImage: [],
                rankHistory: []
            ),
            UserInfo(
                id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
                userName: "김소원",
                userVictoryCnt: 1,
                userTotalScore: 21,
                userImage: [],
                rankHistory: []
            ),
            UserInfo(
                id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
                userName: "허찬욱",
                userVictoryCnt: 0,
                userTotalScore: 18,
                userImage: [],
                rankHistory: []
            )
        ]
    }
}
