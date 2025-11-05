//
//  GuestAuthService.swift
//  NetworkLayer
//
//  Created on 11/2/25.
//

import Foundation
import Combine

/// 게스트 인증 서비스 프로토콜
protocol GuestAuthServiceProtocol {
    func registerGuest(name: String) -> AnyPublisher<GuestRegisterResponse, NetworkError>
    func refresh(refreshToken: String) -> AnyPublisher<TokenResponse, NetworkError>
    func logout() -> AnyPublisher<Void, NetworkError>
    func isAuthenticated() -> Bool
}

/// 게스트 익명 로그인 인증 서비스
class GuestAuthService: GuestAuthServiceProtocol {

    // MARK: - Properties
    private let networkService: NetworkServiceProtocol
    private let tokenManager: TokenManagerProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializer
    init(
        networkService: NetworkServiceProtocol = NetworkService(),
        tokenManager: TokenManagerProtocol = TokenManager()
    ) {
        self.networkService = networkService
        self.tokenManager = tokenManager
    }

    // MARK: - Public Methods

    /// 게스트 회원가입 (이름만 전송, 이미지 업로드 없음)
    /// - Parameter name: 사용자 이름
    /// - Returns: 게스트 등록 응답 (user, accessToken, refreshToken)
    func registerGuest(name: String) -> AnyPublisher<GuestRegisterResponse, NetworkError> {
        return networkService.request(AuthEndpoint.guestRegister(name: name))
            .tryMap { [weak self] (response: GuestRegisterResponse) -> GuestRegisterResponse in
                // 토큰 저장
                try self?.tokenManager.saveTokens(
                    accessToken: response.data.accessToken,
                    refreshToken: response.data.refreshToken
                )
                return response
            }
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                }
                return .unknown(error)
            }
            .eraseToAnyPublisher()
    }

    /// 리프레시 토큰으로 액세스/리프레시 토큰 재발급
    /// - Parameter refreshToken: 리프레시 토큰
    /// - Returns: 새로 발급된 토큰
    func refresh(refreshToken: String) -> AnyPublisher<TokenResponse, NetworkError> {
        return networkService.request(AuthEndpoint.refreshToken(refreshToken: refreshToken))
            .tryMap { [weak self] (response: TokenResponse) -> TokenResponse in
                // 새 토큰 저장
                try self?.tokenManager.saveTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
                return response
            }
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                }
                return .unknown(error)
            }
            .eraseToAnyPublisher()
    }

    /// 로그아웃 (토큰 삭제)
    func logout() -> AnyPublisher<Void, NetworkError> {
        return networkService.request(AuthEndpoint.logout)
            .tryMap { [weak self] (_: EmptyResponse) -> Void in
                // 로컬 토큰 삭제
                try self?.tokenManager.clearTokens()
                return ()
            }
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                }
                return .unknown(error)
            }
            .eraseToAnyPublisher()
    }

    /// 인증 여부 확인
    func isAuthenticated() -> Bool {
        return tokenManager.isAuthenticated()
    }
}

// MARK: - Stub for Testing
class StubGuestAuthService: GuestAuthServiceProtocol {
    func registerGuest(name: String) -> AnyPublisher<GuestRegisterResponse, NetworkError> {
        let data = GuestRegisterData(
            user: User.guestStub,
            accessToken: "stub_access_token",
            refreshToken: "stub_refresh_token"
        )
        let response = GuestRegisterResponse(
            success: true,
            code: "OK",
            message: "Success",
            data: data,
            errors: []
        )
        return Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }

    func refresh(refreshToken: String) -> AnyPublisher<TokenResponse, NetworkError> {
        let response = TokenResponse(
            accessToken: "new_access_token",
            refreshToken: "new_refresh_token"
        )
        return Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }

    func logout() -> AnyPublisher<Void, NetworkError> {
        return Just(())
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }

    func isAuthenticated() -> Bool {
        return false
    }
}
