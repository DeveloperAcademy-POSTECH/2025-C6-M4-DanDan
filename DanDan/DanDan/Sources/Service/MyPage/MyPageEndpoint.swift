//
//  MyPageEndpoint.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/7/25.
//

import Foundation

enum MyPageEndpoint: APIEndpoint {
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



