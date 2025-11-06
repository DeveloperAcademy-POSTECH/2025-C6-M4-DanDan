//
//  UserEndpoint.swift
//  DanDan
//
//  Created by Assistant on 11/6/25.
//

import Foundation

enum UserEndpoint: APIEndpoint {
    case mypage

    var path: String {
        switch self {
        case .mypage:
            return "user/mypage"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .mypage:
            return .get
        }
    }

    var headers: [String : String]? {
        return nil
    }

    var body: [String : Any]? {
        return nil
    }

    var requiresAuthentication: Bool {
        switch self {
        case .mypage:
            return true
        }
    }
}


