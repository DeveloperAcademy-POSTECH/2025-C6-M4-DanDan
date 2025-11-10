//
//  ProfileEditName.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/8/25.
//

import SwiftUI

struct ProfileEditName: View {
    @ObservedObject var viewModel: ProfileEditViewModel

    var body: some View {
        VStack(spacing: 8) {
            CustomTextField(
                text: $viewModel.nickname,
                prompt: "닉네임 입력"
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(viewModel.isNicknameTooLong ? Color.red : Color.clear, lineWidth: 2)
                    .padding(.horizontal, 20)
            )
            .onChange(of: viewModel.nickname) { _, newValue in
                viewModel.onNicknameChanged(newValue)
            }

            Text("닉네임은 7자 이하로 설정해주세요")
                .font(.PR.body4)
                .foregroundColor(.red)
                .frame(height: 20)
                .opacity(viewModel.isNicknameTooLong ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ProfileEditName(viewModel: ProfileEditViewModel())
}
