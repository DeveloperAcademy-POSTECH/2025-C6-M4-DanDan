//
//  Font.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 10/30/25.
//

import SwiftUI

/* 사용예시
    .font(.pretendard(.semiBold, size: 22))

    .font(.PR.title1)
 */

extension Font {
    static func pretendard(_ weight: PretendardWeight, size: CGFloat, elativeTo textStyle: TextStyle = .body) -> Font {
        .custom(weight.rawValue, size: size, relativeTo: textStyle)
    }
    
    enum PR {
        static let title1 = Font.custom("Pretendard-Bold", size: 24, relativeTo: .title)
        static let title2 = Font.custom("Pretendard-SemiBold", size: 20, relativeTo: .title2)
        static let body1 = Font.custom("Pretendard-SemiBold", size: 16, relativeTo: .body)
        static let body2 = Font.custom("Pretendard-Medium", size: 16, relativeTo: .body)
        static let caption1 = Font.custom("Pretendard-Regular", size: 15, relativeTo: .caption)
    }

}

enum PretendardWeight: String {
    case regular = "Pretendard-Regular"
    case medium = "Pretendard-Medium"
    case semiBold = "Pretendard-SemiBold"
    case bold = "Pretendard-Bold"
}
