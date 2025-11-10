//
//  ProfileSetupSectionView.swift
//  DanDan
//
//  Created by Jay on 11/10/25.
//

import SwiftUI
import PhotosUI

struct ProfileSetupSectionView: View {
    @Binding var profileImage: UIImage?
    @Binding var showPicker: Bool
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var nickname: String
    @Binding var isNicknameTooLong: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // 프로필 이미지 업로드 버튼
            AvatarEditButton(
                image: profileImage,
                diameter: 120,
                overlayHeight: 38,
                overlayColor: .darkGreen.opacity(0.8)
            ) {
                showPicker = true
            }
            .photosPicker(isPresented: $showPicker, selection: $selectedItem, matching: .images)
            .padding(.vertical, 10)
            
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
        .padding(.top, 8)
        .onChange(of: nickname) {
            isNicknameTooLong = nickname.count > 7
        }
    }
}

