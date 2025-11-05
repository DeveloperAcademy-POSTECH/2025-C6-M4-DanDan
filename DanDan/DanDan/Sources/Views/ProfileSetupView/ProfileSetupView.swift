//
//  ProfileSetupView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/5/25.
//

import SwiftUI
import PhotosUI

struct ProfileSetupView: View {
    @State private var nickname: String = "" // 서버에 전송할 닉네임
    @State private var selectedItem: PhotosPickerItem?
    @State private var profileImage: UIImage? // 서버에 전송할 이미지
    @State private var showPicker: Bool = false
    
    // MARK: - 서버 콜백 엔트리 포인트
    /// "저장하기" 버튼 탭 시 서버 연동할 부분
    /// nickname과 profileImage를 onSave로 전달
    var onSave: ((_ nickname: String, _ image: UIImage?) -> Void)?
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("회원가입하기")
                        .font(.PR.title1)
                        .foregroundStyle(.steelBlack)
                    
                    Text("나만의 닉네임과 프로필을 설정해주세요.")
                        .font(.PR.caption3)
                        .foregroundStyle(.gray2)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
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
                    "저장하기",
                    action: { onSave?(nickname, profileImage) }, // 여기서 서버 API 호출
                    horizontalPadding: 20,
                    verticalPadding: 8,
                )
                .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
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
