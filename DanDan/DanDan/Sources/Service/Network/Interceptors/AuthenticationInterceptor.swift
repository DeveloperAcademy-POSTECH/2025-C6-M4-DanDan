//
//  AuthenticationInterceptor.swift
//  NetworkLayer
//
//  Created on 11/2/25.
//

import Foundation

/// JWT 인증 인터셉터
/// - 인증이 필요한 요청에 액세스 토큰 자동 추가
/// - 401 에러 발생 시 토큰 갱신 후 재시도
class AuthenticationInterceptor: RequestInterceptor {

    // MARK: - Properties
    private let tokenManager: TokenManagerProtocol
    private let refreshCoordinator = TokenRefreshCoordinator()
    private let maxRetryCount: Int

    /// 토큰 갱신 실패 시 호출되는 클로저 (예: 로그아웃 처리)
    var onRefreshFailure: (() -> Void)?

    // MARK: - Initializer
    init(
        tokenManager: TokenManagerProtocol = TokenManager(),
        maxRetryCount: Int = NetworkConfig.maxRetryCount,
        onRefreshFailure: (() -> Void)? = nil
    ) {
        self.tokenManager = tokenManager
        self.maxRetryCount = maxRetryCount
        self.onRefreshFailure = onRefreshFailure
    }

    // MARK: - RequestInterceptor

    /// 요청에 액세스 토큰 추가
    func adapt(_ request: URLRequest, for endpoint: any APIEndpoint) async throws -> URLRequest {
        // 인증이 필요없는 엔드포인트는 그대로 반환
        print("인증할게유~")
        guard endpoint.requiresAuthentication else {
            print("인증했어유")
            return request
        }

        // 액세스 토큰 조회
        guard let accessToken = try? tokenManager.getAccessToken() else {
            throw NetworkError.unauthorized
        }

        // Authorization 헤더에 토큰 추가
        var authenticatedRequest = request
        authenticatedRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        return authenticatedRequest
    }

    /// 401 에러 발생 시 토큰 갱신 후 재시도
    func retry(_ request: URLRequest, for endpoint: any APIEndpoint, dueTo error: NetworkError) async throws -> RetryResult {
        // 401 Unauthorized가 아니면 재시도 하지 않음
        guard case .httpError(let statusCode, _) = error, statusCode == 401 else {
            return .doNotRetry
        }

        // 인증이 필요없는 엔드포인트는 재시도 안함
        guard endpoint.requiresAuthentication else {
            return .doNotRetry
        }

        // 최대 재시도 횟수 체크 (무한 루프 방지)
        // 실제로는 request에 custom header를 추가해서 재시도 횟수를 추적해야 하지만
        // 간단하게 1회만 재시도하도록 설정
        // TODO: 더 정교한 재시도 카운팅 메커니즘 구현

        do {
            // 토큰 갱신 시도 (동시 갱신 방지)
            let newAccessToken = try await refreshCoordinator.refresh { [weak self] in
                try await self?.performTokenRefresh() ?? ""
            }

            print("✅ 토큰 갱신 성공: \(newAccessToken.prefix(20))...")
            return .retry
        } catch {
            print("❌ 토큰 갱신 실패: \(error)")

            // 토큰 갱신 실패 시 로그아웃 처리
            onRefreshFailure?()

            return .doNotRetry
        }
    }

    // MARK: - Private Methods

    /// 실제 토큰 갱신 수행
    private func performTokenRefresh() async throws -> String {
        // 리프레시 토큰 조회
        guard let refreshToken = try? tokenManager.getRefreshToken() else {
            throw NetworkError.tokenRefreshFailed
        }

        // 토큰 갱신 API 호출
        let endpoint = AuthEndpoint.refreshToken(refreshToken: refreshToken)

        // URLRequest 생성
        guard let url = URL(string: NetworkConfig.baseURL + endpoint.path) else {
            throw NetworkError.invalidRequest
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = NetworkConfig.timeout

        // 헤더 설정
        var headers = NetworkConfig.defaultHeaders
        if let endpointHeaders = endpoint.headers {
            headers.merge(endpointHeaders) { _, new in new }
        }
        request.allHTTPHeaderFields = headers

        // 요청 본문 추가 (refreshToken을 body로 전송)
        if let body = endpoint.body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        }

        // 요청 전송
        let (data, response) = try await URLSession.shared.data(for: request)

        // 응답 검증
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.tokenRefreshFailed
        }

        // 응답 디코딩
        let decoder = JSONDecoder()
        let tokenResponse = try decoder.decode(RefreshTokenResponse.self, from: data)

        // 새 액세스 토큰 저장
        try tokenManager.updateAccessToken(tokenResponse.accessToken)

        // 리프레시 토큰도 갱신되었으면 저장
        if let newRefreshToken = tokenResponse.refreshToken {
            try tokenManager.saveTokens(
                accessToken: tokenResponse.accessToken,
                refreshToken: newRefreshToken
            )
        }

        return tokenResponse.accessToken
    }
}
