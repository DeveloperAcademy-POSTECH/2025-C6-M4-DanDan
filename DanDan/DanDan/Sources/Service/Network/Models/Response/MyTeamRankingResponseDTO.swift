//
//  MyTeamRankingResponseDTO.swift
//  DanDan
//
//  Created by Jay on 11/17/25.
//

import SwiftUI

struct MyTeamRankingResponseDTO: Codable {
    let page: Int
    let limit: Int
    let data: [MyTeamRankingData]
    let errors: [String]
}

struct MyTeamRankingData: Codable, Identifiable {
    let id: String
    let userName: String
    let userImage: String?
    let userWeekScore: Int
    let ranking: Int
    let userTeam: String
    let backgroundColor: String
    let belonging: String
}
