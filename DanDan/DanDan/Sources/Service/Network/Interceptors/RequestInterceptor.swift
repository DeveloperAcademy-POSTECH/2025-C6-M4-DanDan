//
//  RequestInterceptor.swift
//  NetworkLayer
//
//  Created on 11/2/25.
//

import Foundation

/// 요청 재시도 결과
enum RetryResult {
    case retry                              // 즉시 재시도
    case doNotRetry                        // 재시도 하지 않음
    case retryWithDelay(TimeInterval)      // 지연 후 재시도
}

/// 네트워크 요청을 가로채고 수정하는 인터셉터 프로토콜
protocol RequestInterceptor {
    /// 요청을 전송하기 전에 수정
    /// - Parameters:
    ///   - request: 원본 URLRequest
    ///   - endpoint: API 엔드포인트
    /// - Returns: 수정된 URLRequest
    func adapt(_ request: URLRequest, for endpoint: any APIEndpoint) async throws -> URLRequest

    /// 요청 실패 시 재시도 여부 결정
    /// - Parameters:
    ///   - request: 실패한 URLRequest
    ///   - endpoint: API 엔드포인트
    ///   - error: 발생한 NetworkError
    /// - Returns: 재시도 결과
    func retry(_ request: URLRequest, for endpoint: any APIEndpoint, dueTo error: NetworkError) async throws -> RetryResult
}

// MARK: - 기본 구현 (재시도 안함)
extension RequestInterceptor {
    func adapt(_ request: URLRequest, for endpoint: any APIEndpoint) async throws -> URLRequest {
        return request
    }

    func retry(_ request: URLRequest, for endpoint: any APIEndpoint, dueTo error: NetworkError) async throws -> RetryResult {
        return .doNotRetry
    }
}
