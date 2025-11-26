//
//  EmptyResponse.swift
//  NetworkLayer
//
//  Created on 11/2/25.
//

import Foundation

/// 빈 응답을 나타내는 타입
/// 서버에서 응답 본문이 없거나 무시해도 되는 경우 사용
struct EmptyResponse: Decodable {
    // 빈 구조체
}
