//
//  GuestRegisterResponse.swift
//  NetworkLayer
//
//  Created on 11/2/25.
//

import Foundation

/// 게스트 회원가입 응답 데이터
struct GuestRegisterData: Decodable {
    let user: User
    let accessToken: String
    let refreshToken: String
}

/// 게스트 회원가입 응답 래퍼 (서버 표준 응답 형식)
struct GuestRegisterResponse: Decodable {
    let success: Bool
    let code: String
    let message: String
    let data: GuestRegisterData
    let errors: [String]  // 에러 배열 (비어있을 수 있음)

    // meta는 타임스탬프 등의 메타정보를 포함하지만, 클라이언트에서는 사용하지 않으므로 생략
}
