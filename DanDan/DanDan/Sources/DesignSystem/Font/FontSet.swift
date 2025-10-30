//
//  FontSet.swift
//  DanDan
//
//  Created by Jay on 10/31/25.
//

import SwiftUI

enum FontSet {
    enum Name: String {
        case pretendard = "Pretendard"
    }

    enum Size: CGFloat {
        case _8 = 8
        case _10 = 10
        case _12 = 12
        case _14 = 14
    }

    enum Weight: String, CaseIterable {
        case bold = "Bold"
        case medium = "Medium"
        case semibold = "Semibold"

        var fontWeight: Font.Weight {
            switch self {
            case .bold:
                return .bold
            case .medium:
                return .medium
            case .semibold:
                return .semibold
            }
        }
    }
}

extension FontSet {
    static func font(name: Name, size: Size, weight: Weight) -> Font {
        switch name {
        case .pretendard:
            return .custom(
                "\(name.rawValue)-\(weight.rawValue)",
                size: size.rawValue
            )
        }
    }

    static func pretendard(size: Size, weight: Weight = .medium) -> Font {
        return font(name: .pretendard, size: size, weight: weight)
    }
}

extension FontSet {
    private struct CustomFont {
        let name: Name
        let weight: Weight

        var fileName: String {
            "\(name.rawValue)-\(weight.rawValue)"
        }

        var fileExtension: String {
            "otf"
        }
    }

    private static var customFonts: [CustomFont] {
        Weight.allCases.compactMap { weight in
            CustomFont(name: .pretendard, weight: weight)
        }
    }
}
