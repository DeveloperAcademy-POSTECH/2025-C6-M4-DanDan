//
//  RankingEndPoint.swift
//  DanDan
//
//  Created by Jay on 11/5/25.
//

import Foundation

enum RankingEndPoint: APIEndpoint {
    case rankingList
    
    var path: String {
        switch self {
        case .rankingList:
            return "conquest/rankings/overall"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .rankingList:
            return .get
        }
    }
    
    var requiresAuthentication: Bool {
        false
    }
}
