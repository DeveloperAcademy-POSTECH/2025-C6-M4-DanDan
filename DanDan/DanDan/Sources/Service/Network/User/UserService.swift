//
//  UserService.swift
//  DanDan
//
//  Created by Assistant on 11/6/25.
//

import Foundation

protocol UserServiceProtocol {
    func fetchMyPage() async throws -> MyPageAPIResponse
}

final class UserService: UserServiceProtocol {
    private let network: NetworkService = NetworkService()

    func fetchMyPage() async throws -> MyPageAPIResponse {
        return try await network.request(UserEndpoint.mypage)
    }
}


