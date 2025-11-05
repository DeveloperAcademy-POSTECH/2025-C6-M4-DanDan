//
//  MultipartUploadHelper.swift
//  network-module
//
//  Created on 11/2/25.
//

import Foundation
import UIKit

/// Multipart/form-data 업로드 헬퍼
struct MultipartUploadHelper {

    // MARK: - Private Helpers

    /// 이미지 리사이징
    /// - Parameters:
    ///   - image: 원본 이미지
    ///   - maxSize: 최대 가로/세로 크기
    /// - Returns: 리사이징된 이미지
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

    // MARK: - Public Methods

    /// 게스트 회원가입 (이미지 포함)
    /// - Parameters:
    ///   - name: 사용자 이름
    ///   - image: 프로필 이미지 (optional)
    /// - Returns: 게스트 등록 응답
    static func uploadGuestRegister(
        name: String,
        image: UIImage?
    ) async throws -> GuestRegisterResponse {
        // URL 생성
        guard let url = URL(string: NetworkConfig.baseURL + "/auth/guest/register") else {
            throw NetworkError.invalidRequest
        }

        // URLRequest 생성
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30

        // Boundary 생성
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        // Body 데이터 생성
        var body = Data()

        // name 필드 추가
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(name)\r\n".data(using: .utf8)!)

        // 이미지 파일 추가 (있는 경우)
        if let image = image {
            // 이미지 리사이징 (최대 1024x1024)
            let resizedImage = resizeImage(image: image, maxSize: 1024)

            // 압축 시도 (0.8부터 시작해서 5MB 이하가 될 때까지 압축률 증가)
            var imageData: Data?
            var quality: CGFloat = 0.8

            repeat {
                imageData = resizedImage.jpegData(compressionQuality: quality)
                if let data = imageData, Double(data.count) / 1_000_000 <= 5 {
                    break  // 5MB 이하면 성공
                }
                quality -= 0.1  // 압축률 증가
            } while quality > 0.1

            guard let finalImageData = imageData else {
                throw NetworkError.httpError(statusCode: 413, data: Data())
            }

            let sizeInMB = Double(finalImageData.count) / 1_000_000
            if sizeInMB > 5 {
                throw NetworkError.httpError(statusCode: 413, data: Data())
            }

            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(finalImageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        // 종료 바운더리
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        // 요청 전송
        let (data, response) = try await URLSession.shared.data(for: request)

        // 응답 검증
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        // 응답 디코딩
        let decoder = JSONDecoder()

        // 디버그: 서버 응답 출력
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📥 서버 응답 JSON: \(jsonString)")
        }

        do {
            return try decoder.decode(GuestRegisterResponse.self, from: data)
        } catch {
            print("❌ 디코딩 실패: \(error)")
            throw NetworkError.decodingFailed(error as? DecodingError ?? DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Unknown decoding error")))
        }
    }
}
