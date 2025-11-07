//
//  SeasonHistoryEndpoint.swift
//  DanDan
//
//  Created by Assistant on 11/7/25.
//

import Foundation

enum SeasonHistoryEndpoint: APIEndpoint {
    case userHistory(page: Int, size: Int)

    var path: String {
        switch self {
        case let .userHistory(page, size):
            return "conquest/users/history?page=\(page)&size=\(size)"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var requiresAuthentication: Bool {
        // 사용자 기반 API이므로 인증 필요
        true
    }
}


