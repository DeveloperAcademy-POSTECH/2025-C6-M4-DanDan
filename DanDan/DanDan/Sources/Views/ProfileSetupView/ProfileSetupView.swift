//
//  ProfileSetupView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/5/25.
//

import SwiftUI
import PhotosUI

struct ProfileSetupView: View {
    @EnvironmentObject private var nav: NavigationManager
    
    @State private var nickname: String = "" // 서버에 전송할 닉네임
    @State private var selectedItem: PhotosPickerItem?
    @State private var profileImage: UIImage? // 서버에 전송할 이미지
    @State private var showPicker: Bool = false
    
    // 서버 콜백 제거: 온보딩 세션에 직접 저장
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 24) {
            
            TitleSectionView(title: "회원가입하기", description: "나만의 닉네임과 프로필을 설정해주세요.")
                .padding(.top, 58)
            
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
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            
            Spacer()
            
            PrimaryButton(
                "다음으로",
                action: {
                    RegistrationManager.shared.nickname = nickname
                    RegistrationManager.shared.profileImage = profileImage
                    nav.navigate(to: .schoolSelection)
                }, // 여기서 서버 API 호출
                horizontalPadding: 20,
                verticalPadding: 8,
            )
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onChange(of: selectedItem) { newValue in
            guard let item = newValue else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    profileImage = image // profileImage 값
                }
            }
        }
    }
}

#Preview {
    ProfileSetupView()
}
