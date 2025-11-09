//
//  ProfileSetupView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/5/25.
//

import SwiftUI
import PhotosUI

struct ProfileSetupView: View {
    @StateObject private var viewModel = ProfileSetupViewModel()
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var showPicker: Bool = false
    @State private var isNicknameTooLong: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            TitleSectionView(title: "회원가입하기", description: "나만의 닉네임과 프로필을 설정해주세요.")
            
            ProfileSetupSectionView(
                profileImage: $viewModel.profileImage,
                showPicker: $showPicker,
                selectedItem: $selectedItem,
                nickname: $viewModel.nickname,
                isNicknameTooLong: $isNicknameTooLong
            )
            
            Spacer()
            
            PrimaryButton(
                "다음",
                action: {
                    viewModel.tapSchoolSelectionButton()
                },
                isEnabled: !viewModel.nickname.trimmingCharacters(in: .whitespaces).isEmpty && !isNicknameTooLong,
                horizontalPadding: 20,
                verticalPadding: 8,
            )
            .padding(.bottom, 24)
        }
        .padding(.top, 68)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationBarBackButtonHidden(true)
        .onChange(of: selectedItem) { _, newValue in
            guard let item = newValue else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    viewModel.profileImage = image // profileImage 값
                }
            }
        }
    }
}

#Preview {
    ProfileSetupView()
}
