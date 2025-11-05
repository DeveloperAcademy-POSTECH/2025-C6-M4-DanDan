//
//  APIEndpoint.swift
//  NetworkLayer
//
//  Created on 11/2/25.
//

import Foundation

/// HTTP 메서드
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

/// API 엔드포인트 프로토콜
protocol APIEndpoint {
    /// API 경로 (예: "/users/profile")
    var path: String { get }

    /// HTTP 메서드
    var method: HTTPMethod { get }

    /// 추가 헤더 (기본 헤더와 병합됨)
    var headers: [String: String]? { get }

    /// 요청 본문 (JSON으로 직렬화됨)
    var body: [String: Any]? { get }

    /// 인증이 필요한 API인지 여부 (JWT 토큰 추가 여부)
    var requiresAuthentication: Bool { get }
}

// MARK: - 기본 구현
extension APIEndpoint {
    var headers: [String: String]? { nil }
    var body: [String: Any]? { nil }
    var requiresAuthentication: Bool { false }  // 기본값: 인증 불필요
}
