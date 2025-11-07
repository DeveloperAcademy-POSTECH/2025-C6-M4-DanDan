//
//  MyPageService.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/7/25.
//

import Foundation

protocol MyPageServiceProtocol {
    func fetchMyPage() async throws -> MyPageAPIResponse
}

final class MyPageService: MyPageServiceProtocol {
    private let network: NetworkService = NetworkService()

    func fetchMyPage() async throws -> MyPageAPIResponse {
        return try await network.request(MyPageEndpoint.mypage)
    }
}
