//
//  RankingItemData.swift
//  DanDan
//
//  Created by Jay on 11/17/25.
//

import SwiftUI

struct RankingItemData: Identifiable {
    let id: UUID
    let ranking: Int
    let userName: String
    var userImage: UIImage?
    let userWeekScore: Int
    let userTeam: String
    let backgroundColor: Color
    var rankDiff: Int?

    init(
        id: UUID = UUID(),
        ranking: Int,
        userName: String,
        userImage: UIImage?,
        userWeekScore: Int,
        userTeam: String,
        backgroundColor: Color
    ) {
        self.id = id
        self.ranking = ranking
        self.userName = userName
        self.userImage = userImage
        self.userWeekScore = userWeekScore
        self.userTeam = userTeam
        self.backgroundColor = backgroundColor
    }
}
