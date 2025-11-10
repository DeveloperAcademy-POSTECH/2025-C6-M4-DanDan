//
//  TokenManager.swift
//  NetworkLayer
//
//  Created on 11/2/25.
//

import Foundation
import Combine

/// 토큰 관리 프로토콜
protocol TokenManagerProtocol {
    func saveTokens(accessToken: String, refreshToken: String) throws
    func getAccessToken() throws -> String
    func getRefreshToken() throws -> String
    func updateAccessToken(_ accessToken: String) throws
    func clearTokens() throws
    func isAuthenticated() -> Bool
}

/// JWT 토큰 관리자
class TokenManager: TokenManagerProtocol {

    // MARK: - Keys
    private enum Keys {
        static let accessToken = "jwt_access_token"
        static let refreshToken = "jwt_refresh_token"
    }

    // MARK: - Properties
    private let keychainService: KeychainServiceProtocol

    // MARK: - Initializer
    init(keychainService: KeychainServiceProtocol = KeychainService()) {
        self.keychainService = keychainService
    }

    // MARK: - Public Methods

    /// 액세스 토큰과 리프레시 토큰 저장
    func saveTokens(accessToken: String, refreshToken: String) throws {
        guard let accessData = accessToken.data(using: .utf8),
              let refreshData = refreshToken.data(using: .utf8) else {
            throw KeychainError.invalidItemFormat
        }

        try keychainService.save(key: Keys.accessToken, data: accessData)
        try keychainService.save(key: Keys.refreshToken, data: refreshData)
    }

    /// 액세스 토큰 조회
    func getAccessToken() throws -> String {
        let data = try keychainService.read(key: Keys.accessToken)
        guard let token = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidItemFormat
        }
        return token
    }

    /// 리프레시 토큰 조회
    func getRefreshToken() throws -> String {
        let data = try keychainService.read(key: Keys.refreshToken)
        guard let token = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidItemFormat
        }
        return token
    }

    /// 액세스 토큰만 업데이트 (토큰 갱신 후 사용)
    func updateAccessToken(_ accessToken: String) throws {
        guard let accessData = accessToken.data(using: .utf8) else {
            throw KeychainError.invalidItemFormat
        }
        try keychainService.save(key: Keys.accessToken, data: accessData)
    }

    /// 모든 토큰 삭제 (로그아웃)
    func clearTokens() throws {
        try keychainService.delete(key: Keys.accessToken)
        try keychainService.delete(key: Keys.refreshToken)
    }

    /// 인증 여부 확인
    func isAuthenticated() -> Bool {
        do {
            _ = try getAccessToken()
            return true
        } catch {
            return false
        }
    }
}
