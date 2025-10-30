//
//  CustomTextField.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 10/30/25.
//

/*

 사용 방법

 CustomTextField(text: $name, prompt: "입력 전")

 */

import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    var prompt: String

    var body: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(prompt)
                .foregroundStyle(Color(hex: "#A2A9B0")) // 🍭 추후 컬러 Assets 추가 후 변경
        )
//            .prText(Font.PR.body2)  // 추후 Font 디자인 시스템 추가 후 추가
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        .tint(Color(hex: "#262626")) // 커서 색 - 🍭 추후 컬러 Assets 추가 후 변경
        .foregroundColor(Color(hex: "#121212")) // 입력 텍스트 색 - 🍭 추후 컬러 Assets 추가 후 변경
        .background(Color(hex: "#F5F8F2")) // 배경 색 - 🍭 추후 컬러 Assets 추가 후 변경
        .cornerRadius(12)
    }
}

#Preview {
    CustomTextField(text: .constant(""), prompt: "입력되기 전")
}
