//
//  MainMapInfoService.swift
//  DanDan
//
//  Created by Jay on 11/8/25.
//

import Foundation

final class MapService {

    private let tokenManager: TokenManagerProtocol

    // TokenManager를 의존성 주입받도록 구성 (기본값: TokenManager())
    init(tokenManager: TokenManagerProtocol = TokenManager()) {
        self.tokenManager = tokenManager
    }

    /// 메인 맵 정보 조회 API
    func fetchMainMapInfo() async throws -> MainMapInfoResponseDTO {
        guard
            let url = URL(
                string:
                    "https://www.singyupark.cloud:8443/api/v1/conquest/main-map"
            )
        else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // ✅ TokenManager에서 액세스 토큰 불러오기
        do {
            let token = try tokenManager.getAccessToken()
            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization"
            )
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
        let decoded = try JSONDecoder().decode(
            MainMapInfoResponseDTO.self,
            from: data
        )
        return decoded
    }

    func fetchZoneStatuses() async throws -> [ZoneStatus] {
        guard
            let url = URL(
                string:
                    "https://www.singyupark.cloud:8443/api/v1/conquest/zones/status"
            )
        else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
            200..<300 ~= httpResponse.statusCode
        else {
            throw URLError(.badServerResponse)
        }

        let decodedResponse = try JSONDecoder().decode(
            ZoneStatusResponseDTO.self,
            from: data
        )
        return decodedResponse.data
    }
    
    /// 특정 구역(zoneId)의 팀별 점수 조회 API
    func fetchZoneTeamScores(zoneId: Int) async throws -> ZoneTeamScoresData {
        guard
            let url = URL(
                string:
                    "https://www.singyupark.cloud:8443/api/v1/conquest/zones/\(zoneId)/status"
            )
        else {
            throw URLError(.badURL)
        }

        // 요청 전송
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(ZoneTeamScoresResponseDTO.self, from: data)
        return decoded.data
    }
    
    /// 구역별 점령 상태 조회 API
    func fetchZoneStatusDetail() async throws -> [ZoneStatusDetail] {
        guard
            let url = URL(
                string:
                    "https://www.singyupark.cloud:8443/api/v1/conquest/zones/status-detail"
            )
        else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(ZoneStatusDetailResponseDTO.self, from: data)
        
        return decoded.data
    }
}
