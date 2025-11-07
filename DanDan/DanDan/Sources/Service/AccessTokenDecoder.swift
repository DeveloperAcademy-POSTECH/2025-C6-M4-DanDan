//
//  AccessTokenDecoder.swift
//  DanDan
//
//  Created by Jay on 11/8/25.
//


import Foundation

struct AccessTokenDecoder {
    /// JWT Access Token에서 userId(sub)를 추출합니다.
    static func extractUserId(from token: String) -> UUID? {
        // 토큰을 . 기준으로 분리 → header.payload.signature
        let segments = token.split(separator: ".")
        guard segments.count >= 2 else { return nil }

        let payloadSegment = segments[1]

        // Base64 decode
        var base64 = String(payloadSegment)
        // Base64 padding 보정
        let remainder = base64.count % 4
        if remainder > 0 {
            base64.append(String(repeating: "=", count: 4 - remainder))
        }

        guard
            let payloadData = Data(base64Encoded: base64),
            let payloadJSON = try? JSONSerialization.jsonObject(with: payloadData),
            let payloadDict = payloadJSON as? [String: Any],
            let sub = payloadDict["sub"] as? String,
            let uuid = UUID(uuidString: sub)
        else {
            return nil
        }

        return uuid
    }
}
