//
//  Color.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 10/30/25.
//

/*
 
 사용 예시

 .background(Color(hex: "#FF6B6B"))
 
 Text("HEX 예시")
    .background(Color(hex: "#FF6B6B"))


 */

import SwiftUI

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r, g, b, a: Double

        switch hexSanitized.count {
        case 6: // #RRGGBB
            r = Double((rgb & 0xFF0000) >> 16) / 255
            g = Double((rgb & 0x00FF00) >> 8) / 255
            b = Double(rgb & 0x0000FF) / 255
            a = 1.0
        case 8: // #RRGGBBAA
            r = Double((rgb & 0xFF000000) >> 24) / 255
            g = Double((rgb & 0x00FF0000) >> 16) / 255
            b = Double((rgb & 0x0000FF00) >> 8) / 255
            a = Double(rgb & 0x000000FF) / 255
        default:
            r = 1; g = 1; b = 1; a = 1 // 잘못된 값일 때 기본 흰색
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
