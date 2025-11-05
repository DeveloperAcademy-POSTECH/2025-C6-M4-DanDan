//
//  User.swift
//  NetworkLayer
//
//  Created on 11/2/25.
//

import Foundation

/// 사용자 모델
struct User: Decodable {
    let id: String  // UUID
    let name: String
    let profileUrl: String?
    let profileImageKey: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case profileUrl
        case profileImageKey
    }
}

// MARK: - Stub for Testing
extension User {
    static var guestStub: User {
        User(
            id: "uuid-1234-5678",
            name: "산책러",
            profileUrl: nil,
            profileImageKey: nil,
        )
    }

    static var guestWithProfileStub: User {
        User(
            id: "uuid-9876-5432",
            name: "산책러",
            profileUrl: "https://example.com/profile.jpg",
            profileImageKey: "profiles/12345.jpg",
        )
    }
}
