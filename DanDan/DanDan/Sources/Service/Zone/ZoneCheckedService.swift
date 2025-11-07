//
//  ZoneCheckedService.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/6/25.
//

import Foundation

final class ZoneCheckedService {
    static let shared = ZoneCheckedService()
    private let tokenManager: TokenManagerProtocol = TokenManager()
    private init() {}

    // MARK: - Public
    /// 오늘의 산책 체크 상태 조회 (완주한 zoneId 리스트)
    func fetchTodayCheckedZoneIds(completion: @escaping ([Int]) -> Void) {
        Task {
            do {
                let ids = try await fetchToday()
                DispatchQueue.main.async { completion(ids) }
            } catch {
                print("🚨 fetchTodayCheckedZoneIds error:", error)
                DispatchQueue.main.async { completion([]) }
            }
        }
    }

    /// 새 구역 완주 보고 (zoneId 전달)
    func postChecked(zoneId: Int, completion: @escaping (Bool) -> Void) {
        Task {
            do {
                try await complete(zoneId: zoneId)
                DispatchQueue.main.async { completion(true) }
            } catch {
                print("🚨 postChecked error:", error)
                DispatchQueue.main.async { completion(false) }
            }
        }
    }

    // MARK: - Internal request builder
    private func makeRequest(path: String, method: String = "GET", addAuth: Bool, body: Data? = nil) throws -> URLRequest {
        let base = NetworkConfig.baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let normalizedPath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let urlString = "\(base)/\(normalizedPath)"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = method
        applyDefaultHeaders(to: &request)
        if addAuth {
            guard let token = try? tokenManager.getAccessToken() else { throw URLError(.userAuthenticationRequired) }
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = body
        return request
    }

    // MARK: - Private async methods
    private func fetchToday() async throws -> [Int] {
        // 토큰이 없으면 바로 인증 필요 에러 반환
        guard (try? tokenManager.getAccessToken()) != nil else {
            throw URLError(.userAuthenticationRequired)
        }

        // ✅ 인증 필요 엔드포인트: GET walks/daily-check (오늘 완료 구역 조회)
        var request = try makeRequest(path: "walks/daily-check", method: "GET", addAuth: true)
        print("🛰️ GET", request.url?.absoluteString ?? "-", "\nHeaders:", request.allHTTPHeaderFields ?? [:])

        let (data, response) = try await URLSession.shared.data(for: request)
        logResponse(response, data: data)
        try ensure2xx(response, data: data)

        // 본문 파싱: ZoneCheckResponse -> 완료된 구역의 zoneId 리스트만 반환
        let decoded = try JSONDecoder().decode(ZoneCheckResponse.self, from: data)
        let completedZoneIds = decoded.data?.zones.filter { $0.isCompleted }.map { $0.zoneId } ?? []
        return completedZoneIds
    }

    private func complete(zoneId: Int) async throws {
        // ✅ Endpoint: POST walks/complete (per backend spec)
        var request = try makeRequest(path: "walks/complete", method: "POST", addAuth: true)

        let body = ["zoneId": zoneId]
        request.httpBody = try JSONEncoder().encode(body)
        if let bodyStr = String(data: request.httpBody ?? Data(), encoding: .utf8) {
            print("🛰️ POST", request.url?.absoluteString ?? "-", "\nHeaders:", request.allHTTPHeaderFields ?? [:], "\nBody:", bodyStr)
        } else {
            print("🛰️ POST", request.url?.absoluteString ?? "-", "\nHeaders:", request.allHTTPHeaderFields ?? [:], "\nBody: <binary>")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        logResponse(response, data: data)
        if let http = response as? HTTPURLResponse, http.statusCode == 409 {
            // 이미 오늘 완료된 구역인 경우: 멱등 처리로 성공 간주
            print("ℹ️ Already completed today (zoneId=\(zoneId)) — treating as success")
            return
        }
        try ensure2xx(response, data: data)
    }

    // MARK: - Helpers
    private func applyDefaultHeaders(to request: inout URLRequest) {
        NetworkConfig.defaultHeaders.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        request.timeoutInterval = NetworkConfig.timeout
    }

    private func ensure2xx(_ response: URLResponse, data: Data?) throws {
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        guard (200...299).contains(http.statusCode) else {
            let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? "<no body>"
            if http.statusCode == 401 {
                print("🚨 HTTP 401 Unauthorized - body:", body)
                throw URLError(.userAuthenticationRequired)
            }
            if http.statusCode == 403 {
                print("🚨 HTTP 403 Forbidden - body:", body)
                throw URLError(.noPermissionsToReadFile)
            }
            let msg = "HTTP \(http.statusCode) \(HTTPURLResponse.localizedString(forStatusCode: http.statusCode)) - body: \(body)"
            print("🚨 HTTP Error:", msg)
            throw URLError(.badServerResponse)
        }
    }

    private func logResponse(_ response: URLResponse, data: Data?) {
        guard let http = response as? HTTPURLResponse else { return }
        let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? "<no body>"
        print("✅ Response: status=\(http.statusCode), url=\(http.url?.absoluteString ?? "-"), body=\(body)")
    }
    
}
