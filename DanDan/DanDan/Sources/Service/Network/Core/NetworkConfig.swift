//
//  NetworkConfig.swift
//  NetworkLayer
//
//  Created on 11/2/25.
//

import Foundation

/// 네트워크 설정
struct NetworkConfig {
    /// 기본 서버 URL
    static let baseURL = "https://www.singyupark.cloud:8443/api/v1/"

    /// 기본 HTTP 헤더
    static let defaultHeaders: [String: String] = [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Accept-Encoding": "gzip, deflate, br",
        "Connection": "keep-alive"
    ]

    /// 요청 타임아웃 (초)
    static let timeout: TimeInterval = 30

    /// 최대 재시도 횟수 (토큰 갱신 포함)
    static let maxRetryCount = 1
}
