//
//  GuestAuthResponseDTO.swift
//  DanDan
//
//  Created by Jay on 11/7/25.
//

import Foundation

struct GuestAuthResponseDTO: Codable {
    let success: Bool
    let code: String
    let message: String
    let data: GuestAuthData?
    let errors: [GuestAuthError]?
    let meta: GuestAuthMeta?
}

struct GuestAuthData: Codable {
    let userId: UUID
    let userName: String
    let teamName: String
    let accessToken: String
    let refreshToken: String
}

struct GuestAuthError: Codable {
    let statusCode: Int
    let error: String
    let message: String
}

struct GuestAuthMeta: Codable {
    let timestamp: String
    let path: String
}
