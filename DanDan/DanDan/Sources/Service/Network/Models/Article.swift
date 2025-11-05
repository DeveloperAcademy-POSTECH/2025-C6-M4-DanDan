//
//  Article.swift
//  NetworkLayer
//
//  Created on 11/2/25.
//

import Foundation

/// 기사/게시물 모델 (예시)
struct Article: Decodable {
    let id: Int
    let title: String
    let content: String
    let publishedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case publishedAt = "published_at"
    }
}
