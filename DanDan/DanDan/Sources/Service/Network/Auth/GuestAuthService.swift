//
//  GuestAuthService.swift
//  NetworkLayer
//
//  Created on 11/2/25.
//

import Combine
import Foundation
import UIKit

/// 게스트 인증 서비스 프로토콜
protocol GuestAuthServiceProtocol {
    func registerGuest(name: String) -> AnyPublisher<GuestRegisterResponse, NetworkError>
    func refresh(refreshToken: String) -> AnyPublisher<TokenResponse, NetworkError>
    func logout() -> AnyPublisher<Void, NetworkError>
    func isAuthenticated() -> Bool
}

/// 게스트 익명 로그인 인증 서비스
class GuestAuthService: GuestAuthServiceProtocol {
    // MARK: - Properties

    private let networkService: NetworkServiceProtocol
    private let tokenManager: TokenManagerProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializer

    init(
        networkService: NetworkServiceProtocol = NetworkService(),
        tokenManager: TokenManagerProtocol = TokenManager()
    ) {
        self.networkService = networkService
        self.tokenManager = tokenManager
    }

    // MARK: - Public Methods

    /// 게스트 회원가입 (이름만 전송, 이미지 업로드 없음)
    /// - Parameter name: 사용자 이름
    /// - Returns: 게스트 등록 응답 (user, accessToken, refreshToken)
    func registerGuest(name: String) -> AnyPublisher<GuestRegisterResponse, NetworkError> {
        return networkService.request(AuthEndpoint.guestRegister(name: name))
            .tryMap { [weak self] (response: GuestRegisterResponse) -> GuestRegisterResponse in
                // 토큰 저장
                try self?.tokenManager.saveTokens(
                    accessToken: response.data.accessToken,
                    refreshToken: response.data.refreshToken
                )
                return response
            }
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                }
                return .unknown(error)
            }
            .eraseToAnyPublisher()
    }

    private static func resizeImage(image: UIImage, maxSize: CGFloat) -> UIImage {
        let size = image.size

        // 이미 maxSize보다 작으면 그대로 반환
        if size.width <= maxSize && size.height <= maxSize {
            return image
        }

        // 비율 계산
        let widthRatio = maxSize / size.width
        let heightRatio = maxSize / size.height
        let ratio = min(widthRatio, heightRatio)

        // 새 크기 계산
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        // 리사이징
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage ?? image
    }

    /// 게스트 회원가입 (팀 이름 + 유저 이름 + 이미지 포함)
    func registerGuest(
        teamName: String,
        userName: String,
        profileImage: UIImage?
    ) async throws -> GuestAuthResponseDTO {
        // ✅ 1. URL 생성
        guard let url = URL(string: "https://www.singyupark.cloud:8443/api/v1/auth/guest/register/by-team-name")
        else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30

        // ✅ 2. Boundary 생성 및 Content-Type 설정
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // ✅ 3. Body 생성
        var body = Data()

        // teamName
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"teamName\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(teamName)\r\n".data(using: .utf8)!)

        // userName
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(userName)\r\n".data(using: .utf8)!)

        // ✅ 4. 이미지 추가 (선택적)
        if let image = profileImage {
            // 이미지 리사이징 (최대 1024x1024)
            let resizedImage = GuestAuthService.resizeImage(image: image, maxSize: 1024)

            // JPEG 압축 (최대 5MB)
            var imageData: Data?
            var quality: CGFloat = 0.8
            repeat {
                imageData = resizedImage.jpegData(compressionQuality: quality)
                if let data = imageData, Double(data.count) / 1_000_000 <= 5 {
                    break
                }
                quality -= 0.1
            } while quality > 0.1

            guard let finalImageData = imageData else {
                throw URLError(.dataLengthExceedsMaximum)
            }

            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(finalImageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        // ✅ 5. 종료 Boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        // ✅ 6. 요청 전송
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200 ... 299).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }

        // ✅ 7. 응답 디코드
        let decoder = JSONDecoder()

        if let json = String(data: data, encoding: .utf8) {
            print("📥 서버 응답 JSON:", json)
        }

        do {
            let response = try decoder.decode(GuestAuthResponseDTO.self, from: data)

            let responseData = response.data
            try tokenManager.saveTokens(
                accessToken: responseData.accessToken,
                refreshToken: responseData.refreshToken
            )

            return response
        } catch {
            print("❌ 디코딩 실패:", error)
            throw error
        }
    }

    /// 리프레시 토큰으로 액세스/리프레시 토큰 재발급
    /// - Parameter refreshToken: 리프레시 토큰
    /// - Returns: 새로 발급된 토큰
    func refresh(refreshToken: String) -> AnyPublisher<TokenResponse, NetworkError> {
        return networkService.request(AuthEndpoint.refreshToken(refreshToken: refreshToken))
            .tryMap { [weak self] (response: TokenResponse) -> TokenResponse in
                // 새 토큰 저장
                try self?.tokenManager.saveTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
                return response
            }
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                }
                return .unknown(error)
            }
            .eraseToAnyPublisher()
    }

    /// 로그아웃 (토큰 삭제)
    func logout() -> AnyPublisher<Void, NetworkError> {
        return networkService.request(AuthEndpoint.logout)
            .tryMap { [weak self] (_: EmptyResponse) in
                // 로컬 토큰 삭제
                try self?.tokenManager.clearTokens()
                // 로컬 사용자 상태 초기화
                StatusManager.shared.resetUserStatus()
                return ()
            }
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                }
                return .unknown(error)
            }
            .eraseToAnyPublisher()
    }

    /// 인증 여부 확인
    func isAuthenticated() -> Bool {
        return tokenManager.isAuthenticated()
    }
}

// MARK: - Stub for Testing

class StubGuestAuthService: GuestAuthServiceProtocol {
    func registerGuest(name: String) -> AnyPublisher<GuestRegisterResponse, NetworkError> {
        let data = GuestRegisterData(
            user: User.guestStub,
            accessToken: "stub_access_token",
            refreshToken: "stub_refresh_token"
        )
        let response = GuestRegisterResponse(
            success: true,
            code: "OK",
            message: "Success",
            data: data,
            errors: []
        )
        return Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }

    func refresh(refreshToken: String) -> AnyPublisher<TokenResponse, NetworkError> {
        let response = TokenResponse(
            accessToken: "new_access_token",
            refreshToken: "new_refresh_token"
        )
        return Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }

    func logout() -> AnyPublisher<Void, NetworkError> {
        return Just(())
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }

    func isAuthenticated() -> Bool {
        return false
    }
}
