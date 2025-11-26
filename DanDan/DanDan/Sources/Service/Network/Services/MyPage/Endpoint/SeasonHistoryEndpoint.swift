//
//  SeasonHistoryEndpoint.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/8/25.
//

import Foundation

enum SeasonHistoryEndpoint: APIEndpoint {
    case userHistory(page: Int, size: Int)
    case userZoneScores(periodId: String?)

    var path: String {
        switch self {
        case let .userHistory(page, size):
            return "conquest/users/history?page=\(page)&size=\(size)"
        case let .userZoneScores(periodId):
            if let pid = periodId, !pid.isEmpty {
                return "conquest/users/zone-scores?periodId=\(pid)"
            } else {
                // periodId 미지정 시 현재 기간 기준
                return "conquest/users/zone-scores"
            }
        }
    }

    var method: HTTPMethod {
        .get
    }

    var requiresAuthentication: Bool {true}
}


