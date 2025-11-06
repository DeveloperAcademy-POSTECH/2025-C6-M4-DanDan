//
//  TokenResponse.swift
//  NetworkLayer
//
//  Created on 11/2/25.
//

import Foundation

/// 토큰 응답 DTO
struct TokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"  // 서버 응답에 맞게 수정
        case refreshToken = "refresh_token"
    }
}

/// 토큰 갱신 응답 DTO (일부 서버는 access token만 반환)
struct RefreshTokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String?  // optional (서버에 따라 refresh token은 재발급 안될 수도 있음)

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}
