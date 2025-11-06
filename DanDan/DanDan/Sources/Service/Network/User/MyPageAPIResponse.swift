//
//  MyPageAPIResponse.swift
//  DanDan
//
//  Created by Assistant on 11/6/25.
//

import Foundation

struct MyPageAPIResponse: Decodable {
    let code: String
    let message: String
    let data: MyPageData
    let errors: [String]
    let meta: MyPageMeta?
}

struct MyPageData: Decodable {
    let user: MyPageUser
    let currentWeekActivity: MyPageCurrentWeek
}

struct MyPageUser: Decodable {
    let profileUrl: String?
    let userName: String
    let userVictoryCnt: Int
    let userTotalScore: Int
    let userTeam: String
}

struct MyPageCurrentWeek: Decodable {
    let userWeekScore: Int
    let ranking: Int
    let weekIndex: Int
    let startDate: String
    let endDate: String
}

struct MyPageMeta: Decodable {
    let timestamp: String?
    let path: String?
    let requestId: String?
    let version: String?
    let durationMs: Int?
}


