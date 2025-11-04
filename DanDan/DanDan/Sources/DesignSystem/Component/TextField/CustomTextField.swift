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
                .foregroundStyle(.gray4)
        )
        .font(.PR.body3)
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        .tint(.steelBlack)
        .foregroundColor(.steelBlack)
        .background(.lightGreen)
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
}

#Preview {
    CustomTextField(text: .constant(""), prompt: "입력되기 전")
}
