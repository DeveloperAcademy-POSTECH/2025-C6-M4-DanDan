//
//  ProfileEditName.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/8/25.
//

import SwiftUI

struct ProfileEditName: View {
    @Binding var text: String
    let isNicknameTooLong: Bool
    let onNicknameChanged: (String) -> Void

    var body: some View {
        VStack(spacing: 8) {
            CustomTextField(
                text: $text,
                prompt: "닉네임 입력"
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isNicknameTooLong ? .red : Color.clear, lineWidth: 2)
                    .padding(.horizontal, 20)
            )
            .onChange(of: text) { _, newValue in
                onNicknameChanged(newValue)
            }

            Text("닉네임은 7자 이하로 설정해주세요")
                .font(.PR.body4)
                .foregroundColor(.red)
                .frame(height: 20)
                .opacity(isNicknameTooLong ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    @Previewable @State var name: String = ""
    ProfileEditName(
        text: $name,
        isNicknameTooLong: false,
        onNicknameChanged: { _ in }
    )
}
