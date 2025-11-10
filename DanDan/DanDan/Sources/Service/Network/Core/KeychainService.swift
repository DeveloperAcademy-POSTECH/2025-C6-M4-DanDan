//
//  KeychainService.swift
//  NetworkLayer
//
//  Created on 11/2/25.
//

import Foundation
import Security

/// Keychain 에러
enum KeychainError: Error {
    case itemNotFound           // 항목을 찾을 수 없음
    case duplicateItem          // 중복된 항목
    case invalidItemFormat      // 잘못된 항목 형식
    case unexpectedStatus(OSStatus)  // 예상치 못한 상태
}

// MARK: - LocalizedError
extension KeychainError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return "아이템을 찾을 수 없습니다."
        case .duplicateItem:
            return "중복된 아이템입니다."
        case .invalidItemFormat:
            return "잘못된 아이템 형식입니다."
        case .unexpectedStatus(let status):
            return "키체인 오류 (상태 코드: \(status))"
        }
    }
}

/// Keychain 서비스 프로토콜
protocol KeychainServiceProtocol {
    func save(key: String, data: Data) throws
    func read(key: String) throws -> Data
    func delete(key: String) throws
}

/// Keychain 서비스 구현
class KeychainService: KeychainServiceProtocol {
    private let service: String

    init(service: String = Bundle.main.bundleIdentifier ?? "com.networkLayer") {
        self.service = service
    }

    func save(key: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        // 기존 항목 삭제 (중복 방지)
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)

        if status != errSecSuccess {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    func read(key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }

        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }

        guard let data = item as? Data else {
            throw KeychainError.invalidItemFormat
        }

        return data
    }

    func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}
