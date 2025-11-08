//
//  ProFileEditView.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/2/25.
//

import PhotosUI
import SwiftUI

struct ProfileEditView: View {
    @State private var nickname: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var profileImage: UIImage? = UIImage(named: "default_avatar")
    @State private var showPicker: Bool = false
    @State private var isNicknameTooLong: Bool = false

    var body: some View {
        VStack(spacing: 45) {
            
            ProfileTitle(
                title: "프로필 수정하기",
                description: "나만의 닉네임과 프로필을 설정해주세요."
            )

            VStack(spacing: 40) {
                AvatarEditButton(
                    image: profileImage,
                    diameter: 120,
                    overlayHeight: 38,
                    overlayColor: .darkGreen.opacity(0.8)
                ) {
                    showPicker = true
                }
                .photosPicker(isPresented: $showPicker, selection: $selectedItem, matching: .images)

                CustomTextField(text: $nickname, prompt: "닉네임 입력")
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isNicknameTooLong ? Color.red : Color.clear, lineWidth: 1)
                            .padding(.horizontal, 20)
                    )
                if isNicknameTooLong {
                    Text("닉네임은 7자 이하로 설정해주세요")
                        .font(.PR.body4)
                        .foregroundColor(.red)
                        .padding(.leading, 4)
                        .padding(.top, -12)
                }
            }
            .frame(maxWidth: .infinity)

            Spacer()

            PrimaryButton(
                "수정하기",
                action: { () }
            )
        }
    }
}

#Preview {
    ProfileEditView()
}
