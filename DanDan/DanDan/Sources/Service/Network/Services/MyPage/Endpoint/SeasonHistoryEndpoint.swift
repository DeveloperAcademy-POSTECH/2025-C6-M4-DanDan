//
//  SeasonHistoryEndpoint.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/8/25.
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

    var requiresAuthentication: Bool {true}
}


