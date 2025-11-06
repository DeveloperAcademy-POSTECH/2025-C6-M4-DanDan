//
//  NetworkService.swift
//  NetworkLayer
//
//  Created on 11/2/25.
//

import Combine
import Foundation

/// ✅ 네트워크 요청 공통 인터페이스 프로토콜
protocol NetworkServiceProtocol {
    /// - Parameter endpoint: 요청할 API 엔드포인트
    /// - Returns: Combine Publisher (디코딩된 모델 or NetworkError)
    func request<T: Decodable>(_ endpoint: any APIEndpoint) -> AnyPublisher<
        T, NetworkError
    >
}

/// ✅ 실제 네트워크 요청을 수행하는 서비스 클래스
class NetworkService: NetworkServiceProtocol {

    // MARK: - Properties
    /// 서버의 기본 URL
    private let baseURL: URL
    /// URLSession 인스턴스 (기본값: .shared)
    private let session: URLSession
    /// 인증/재시도 등을 담당하는 요청 인터셉터 배열
    private let interceptors: [RequestInterceptor]

    // MARK: - Initializer

    /// 기본 생성자
    /// - Parameters:
    ///   - baseURL: 서버 기본 URL (기본값: NetworkConfig.baseURL)
    ///   - session: 사용할 URLSession (기본값: .shared)
    ///   - interceptors: 요청 전/후 처리용 인터셉터 배열
    init(
        baseURL: String = NetworkConfig.baseURL,
        session: URLSession = .shared,
        interceptors: [RequestInterceptor] = [AuthenticationInterceptor()]
    ) {
        guard let url = URL(string: baseURL) else {
            fatalError("Invalid base URL: \(baseURL)")
        }
        self.baseURL = url
        self.session = session
        self.interceptors = interceptors
    }

    // MARK: - NetworkServiceProtocol

    /// ✅ 네트워크 요청을 수행하고 Combine Publisher로 반환합니다.
    func request<T: Decodable>(_ endpoint: any APIEndpoint) -> AnyPublisher<
        T, NetworkError
    > {
        // async/await 기반 비동기 요청을 Combine Future로 래핑
        return Future<T, NetworkError> { [weak self] promise in
            Task {
                do {
                    // 실제 요청 실행 (performRequest)
                    let result: T =
                        try await self?.performRequest(endpoint)
                        ?? {
                            throw NetworkError.unknown(
                                NSError(domain: "NetworkService", code: -1)
                            )
                        }()

                    promise(.success(result))  // ✅ 성공 시 데이터 반환
                } catch let error as NetworkError {
                    promise(.failure(error))  // ❌ 네트워크 오류
                } catch {
                    promise(.failure(.unknown(error)))  // ❌ 알 수 없는 오류
                }
            }
        }
        .eraseToAnyPublisher()  // Combine 외부에 타입 노출 방지
    }

    // MARK: - Private Methods

    /// ✅ 실제 네트워크 요청 수행 (async/await)
    private func performRequest<T: Decodable>(_ endpoint: any APIEndpoint)
        async throws -> T
    {
        // 1️⃣ URLRequest 생성
        guard var request = createRequest(for: endpoint) else {
            throw NetworkError.invalidRequest
        }

        // 2️⃣ 인터셉터 체인 실행: 요청 수정 (예: 토큰 추가)
        for interceptor in interceptors {
            request = try await interceptor.adapt(request, for: endpoint)
        }

        // 3️⃣ 재시도 로직 관련 변수 설정
        var retryCount = 0
        let maxRetries = NetworkConfig.maxRetryCount

        // 4️⃣ 요청 수행 (최대 재시도 횟수만큼 반복)
        while retryCount <= maxRetries {
            do {
                // ✅ 실제 요청 전송
                let (data, response) = try await session.data(for: request)

                if let raw = String(data: data, encoding: .utf8) {
                        print("📦 [DEBUG] Raw Response Body:\n\(raw)")
                    }
                
                // ✅ 응답 유효성 검증
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }

                // ✅ 상태 코드(200~299) 확인
                guard (200...299).contains(httpResponse.statusCode) else {
                    let error = NetworkError.httpError(
                        statusCode: httpResponse.statusCode,
                        data: data
                    )

                    // ❗️인터셉터를 통해 재시도 여부 결정 (예: 토큰 갱신)
                    let shouldRetry = try await shouldRetryRequest(
                        request,
                        for: endpoint,
                        dueTo: error
                    )

                    if shouldRetry {
                        retryCount += 1
                        // 토큰이 갱신되었을 가능성이 있으므로 adapt 재실행
                        for interceptor in interceptors {
                            request = try await interceptor.adapt(
                                request,
                                for: endpoint
                            )
                        }
                        continue  // ➡️ 다시 루프 반복 (재시도)
                    } else {
                        throw error  // ❌ 재시도 불가 시 즉시 종료
                    }
                }

                // ✅ 성공 시 JSON → Decodable 모델 변환
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase  // 서버 snake_case 자동 변환
                let decodedData = try decoder.decode(T.self, from: data)
                return decodedData

            } catch let error as NetworkError {
                // ❌ 이미 NetworkError라면 그대로 throw
                switch error {
                case .httpError(let statusCode, let data):
                    print("❌ HTTP Error \(statusCode)")

                    if let body = String(data: data, encoding: .utf8) {
                        print("📦 Server Response Body:\n\(body)")
                    } else {
                        print("⚠️ No readable response body")
                    }

                default:
                    print("❌ NetworkError: \(error.localizedDescription)")
                }
                throw error

            } catch let decodingError as DecodingError {
                // ❌ JSON 파싱 실패
                throw NetworkError.decodingFailed(decodingError)
            } catch {
                // ❌ 기타 요청 실패
                throw NetworkError.requestFailed(error)
            }
        }

        // 🔚 모든 재시도 후에도 실패 시
        throw NetworkError.unknown(
            NSError(
                domain: "NetworkService",
                code: -2,
                userInfo: [
                    NSLocalizedDescriptionKey: "Max retry count exceeded"
                ]
            )
        )
    }

    // MARK: - Async API
    /// ✅ 네트워크 요청을 async/await로 직접 호출할 수 있는 퍼블릭 메서드
    func request<T: Decodable>(_ endpoint: any APIEndpoint) async throws -> T {
        return try await performRequest(endpoint)
    }

    /// ✅ 요청 실패 시 재시도 여부 판단
    private func shouldRetryRequest(
        _ request: URLRequest,
        for endpoint: any APIEndpoint,
        dueTo error: NetworkError
    ) async throws -> Bool {
        for interceptor in interceptors {
            let result = try await interceptor.retry(
                request,
                for: endpoint,
                dueTo: error
            )

            switch result {
            case .retry:
                return true  // 즉시 재시도
            case .doNotRetry:
                continue  // 다음 인터셉터 판단으로 넘어감
            case .retryWithDelay(let delay):
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                return true  // 일정 지연 후 재시도
            }
        }
        return false  // 모든 인터셉터가 재시도 불가 시 종료
    }

    /// ✅ 엔드포인트를 기반으로 URLRequest 생성
    private func createRequest(for endpoint: any APIEndpoint) -> URLRequest? {
        // 상대 경로를 baseURL과 결합해 완전한 URL 생성
        guard let url = URL(string: endpoint.path, relativeTo: baseURL) else {
            return nil
        }

        print("\(url)")
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = NetworkConfig.timeout

        // ✅ 기본 헤더 + 엔드포인트 개별 헤더 병합
        var headers = NetworkConfig.defaultHeaders
        if let endpointHeaders = endpoint.headers {
            headers.merge(endpointHeaders) { _, new in new }
        }
        request.allHTTPHeaderFields = headers

        // ✅ 요청 본문 (body) 추가 (POST/PUT 요청 등)
        if let body = endpoint.body {
            do {
                request.httpBody = try JSONSerialization.data(
                    withJSONObject: body,
                    options: []
                )
            } catch {
                print("❌ Error serializing request body: \(error)")
                return nil
            }
        }

        return request
    }
}
