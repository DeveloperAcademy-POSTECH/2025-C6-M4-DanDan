//
//  MainMapInfoService.swift
//  DanDan
//
//  Created by Jay on 11/8/25.
//

import Foundation

final class MainMapInfoService {

    private let tokenManager: TokenManagerProtocol

    // TokenManager를 의존성 주입받도록 구성 (기본값: TokenManager())
    init(tokenManager: TokenManagerProtocol = TokenManager()) {
        self.tokenManager = tokenManager
    }

    /// 메인 맵 정보 조회 API
    func fetchMainMapInfo() async throws -> MainMapInfoResponseDTO {
        guard let url = URL(string: "https://www.singyupark.cloud:8443/api/v1/conquest/main-map") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // ✅ TokenManager에서 액세스 토큰 불러오기
        do {
            let token = try tokenManager.getAccessToken()
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } catch {
            print("⚠️ 액세스 토큰 없음 — 로그인 필요")
            throw error
        }

        // 요청 전송
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        print("📡 Status Code:", httpResponse.statusCode)
        if let json = String(data: data, encoding: .utf8) {
            print("📥 Response Body:\n\(json)")
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            print("❌ 서버 응답 오류 (\(httpResponse.statusCode))")
            throw URLError(.badServerResponse)
        }

        // JSON 디코딩
        let decoded = try JSONDecoder().decode(MainMapInfoResponseDTO.self, from: data)
        return decoded
    }
}
