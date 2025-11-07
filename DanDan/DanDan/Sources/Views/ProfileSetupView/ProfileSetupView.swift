//
//  ProfileSetupView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/5/25.
//

import SwiftUI
import PhotosUI

struct ProfileSetupView: View {
    private let navigationManager = NavigationManager.shared
    
    @State private var nickname: String = "" // 서버에 전송할 닉네임
    @State private var selectedItem: PhotosPickerItem?
    @State private var profileImage: UIImage? = UIImage(named: "default_avatar") // 서버에 전송할 이미지
    @State private var showPicker: Bool = false
    @State private var isNicknameTooLong: Bool = false
    
    // MARK: - 서버 콜백 엔트리 포인트
    /// "저장하기" 버튼 탭 시 서버 연동할 부분
    /// nickname과 profileImage를 onSave로 전달
    var onSave: ((_ nickname: String, _ image: UIImage?) -> Void)?
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 24) {
            
            TitleSectionView(title: "회원가입하기", description: "나만의 닉네임과 프로필을 설정해주세요.")
            
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
            .onChange(of: nickname) { newValue in
                isNicknameTooLong = newValue.count > 7
            }
            
            Spacer()
            
            PrimaryButton(
                "다음",
                action: {
                    navigationManager.navigate(to: .schoolSelection(nickname: nickname, image: profileImage))
                    onSave?(nickname, profileImage)
                }, // 여기서 서버 API 호출
                isEnabled: !nickname.trimmingCharacters(in: .whitespaces).isEmpty && !isNicknameTooLong,
                horizontalPadding: 20,
                verticalPadding: 8,
            )
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        
        .onChange(of: selectedItem) { _, newValue in
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
