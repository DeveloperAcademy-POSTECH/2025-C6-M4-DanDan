//
//  AuthEndpoint.swift
//  NetworkLayer
//
//  Created on 11/2/25.
//

import Foundation

/// 인증 관련 API 엔드포인트 (게스트 익명 로그인)
enum AuthEndpoint: APIEndpoint {
    case guestRegister(name: String)
    case refreshToken(refreshToken: String)
    case logout

    var path: String {
        switch self {
        case .guestRegister:
            return "/auth/guest/register"
        case .refreshToken:
            return "/auth/guest/refresh"
        case .logout:
            return "/auth/logout"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .guestRegister, .refreshToken, .logout:
            return .post
        }
    }

    var headers: [String: String]? {
        // 모든 요청은 기본 헤더 사용
        return nil
    }

    var body: [String: Any]? {
        switch self {
        case .guestRegister(let name):
            // 이미지 업로드 없는 경우 (JSON으로 전송)
            // multipart/form-data는 별도 처리 필요
            return ["name": name]
        case .refreshToken(let refreshToken):
            // refreshToken을 body로 전송 (백엔드 API 사양)
            return ["refreshToken": refreshToken]
        case .logout:
            return nil
        }
    }

    var requiresAuthentication: Bool {
        switch self {
        case .guestRegister, .refreshToken:
            return false  // 인증 불필요 (회원가입, 토큰 갱신)
        case .logout:
            return true   // 로그아웃은 인증 필요
        }
    }
}
