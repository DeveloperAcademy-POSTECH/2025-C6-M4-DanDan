//
//  Font.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 10/30/25.
//

import SwiftUI

/* 사용예시
    .font(.pretendard(.semiBold, size: 22))
 
     Text("철길숲 산책 기록")
         .prText(Font.PR.title1)
 */

struct PRTextStyle {
    let font: Font
    let lineSpacing: CGFloat
}

extension Font {
    static func pretendard(_ weight: PretendardWeight, size: CGFloat) -> Font {
        .custom(weight.rawValue, size: size)
    }
    
    enum PR {
        static let title1 = PRTextStyle(font: .custom("Pretendard-Bold", size: 24), lineSpacing: 32)
        static let title2 = PRTextStyle(font: .custom("Pretendard-SemiBold", size: 20), lineSpacing: 22)
        static let body1  = PRTextStyle(font: .custom("Pretendard-SemiBold", size: 16), lineSpacing: 22)
        static let body2  = PRTextStyle(font: .custom("Pretendard-Medium", size: 16), lineSpacing: 22)
        static let caption1 = PRTextStyle(font: .custom("Pretendard-Regular", size: 15), lineSpacing: 22)
    }
}

struct PRTextModifier: ViewModifier {
    let style: PRTextStyle
    
    func body(content: Content) -> some View {
        content
            .font(style.font)
            .lineSpacing(style.lineSpacing)
    }
}

extension View {
    func prText(_ style: PRTextStyle) -> some View {
        self.modifier(PRTextModifier(style: style))
    }
}

enum PretendardWeight: String {
    case regular = "Pretendard-Regular"
    case medium = "Pretendard-Medium"
    case semiBold = "Pretendard-SemiBold"
    case bold = "Pretendard-Bold"
}
