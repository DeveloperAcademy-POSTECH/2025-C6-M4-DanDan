//
//  NetworkError.swift
//  NetworkLayer
//
//  Created on 11/2/25.
//

import Foundation

/// 네트워크 에러
enum NetworkError: Error, Equatable {
    case invalidRequest                     // 잘못된 요청
    case invalidResponse                    // 유효하지 않은 응답
    case requestFailed(Error)              // 네트워크 요청 실패
    case httpError(statusCode: Int, data: Data)  // HTTP 에러
    case decodingFailed(DecodingError)     // 디코딩 실패
    case unauthorized                       // 401 Unauthorized
    case tokenExpired                       // 토큰 만료
    case tokenRefreshFailed                 // 토큰 갱신 실패
    case unknown(Error)                     // 알 수 없는 에러

    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidRequest, .invalidRequest),
             (.invalidResponse, .invalidResponse),
             (.unauthorized, .unauthorized),
             (.tokenExpired, .tokenExpired),
             (.tokenRefreshFailed, .tokenRefreshFailed):
            return true
        case (.requestFailed, .requestFailed):
            return true
        case (.httpError(let lhsCode, _), .httpError(let rhsCode, _)):
            return lhsCode == rhsCode
        case (.decodingFailed, .decodingFailed):
            return true
        case (.unknown, .unknown):
            return true
        default:
            return false
        }
    }
}

// MARK: - LocalizedError
extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "잘못된 요청입니다. 다시 시도해주세요."
        case .invalidResponse:
            return "서버로부터 유효하지 않은 응답을 받았습니다."
        case .requestFailed(let error):
            return "네트워크 요청 실패: \(error.localizedDescription)"
        case .httpError(let statusCode, _):
            switch statusCode {
            case 413:
                return "이미지 파일이 너무 큽니다. 더 작은 이미지를 선택해주세요."
            case 400:
                return "잘못된 요청입니다. 입력 정보를 확인해주세요."
            case 401:
                return "인증이 필요합니다."
            case 403:
                return "접근 권한이 없습니다."
            case 404:
                return "요청한 리소스를 찾을 수 없습니다."
            case 500...599:
                return "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
            default:
                return "서버 오류 (코드: \(statusCode))"
            }
        case .decodingFailed:
            return "데이터 디코딩 실패: 서버 응답 형식이 예상과 다릅니다."
        case .unauthorized:
            return "인증이 필요합니다. 다시 로그인해주세요."
        case .tokenExpired:
            return "토큰이 만료되었습니다. 다시 로그인해주세요."
        case .tokenRefreshFailed:
            return "토큰 갱신에 실패했습니다. 다시 로그인해주세요."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다. 다시 시도해주세요."
        }
    }
}
