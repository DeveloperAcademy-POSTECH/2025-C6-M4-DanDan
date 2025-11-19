//
//  ProFileEditView.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/2/25.
//

import SwiftUI
import Combine

struct ProfileEditView: View {
    @StateObject private var viewModel = ProfileEditViewModel()
    @State private var isKeyboardVisible: Bool = false

    private var needsCustomBackButton: Bool {
        if #available(iOS 26.0, *) { return false } else { return true }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                ProfileTitle(
                    title: "프로필 수정하기",
                    description: "나만의 닉네임과 프로필을 설정해주세요."
                )
                
                ProfileEditImage(
                    image: viewModel.profileImage,
                    canDelete: viewModel.canDeleteImage,
                    onPickImage: { image in
                        viewModel.setNewImage(image)
                    },
                    onRemoveImage: {
                        viewModel.removeImage()
                    }
                )

                ProfileEditName(
                    text: $viewModel.nickname,
                    isNicknameTooLong: viewModel.isNicknameTooLong,
                    onNicknameChanged: { newValue in
                        viewModel.onNicknameChanged(newValue)
                    }
                )
            }
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .safeAreaInset(edge: .bottom) {
            ProfileEditSaveButton(
                isEnabled: viewModel.isSaveEnabled,
                onSave: {
                    try await viewModel.save()
                }
            )
        }
        .task {
            await viewModel.load()
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true }
                .merge(with:
                    NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                        .map { _ in false }
                )
        ) { isVisible in
            isKeyboardVisible = isVisible
        }
        .scrollDisabled(!isKeyboardVisible)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton { viewModel.handleBackTapped() }
            }
        }
        .alert("저장되지 않아요 !", isPresented: $viewModel.showDiscardAlert) {
            Button("계속 수정하기", role: .cancel) {}
            Button("뒤로가기", role: .destructive) {
                viewModel.confirmDiscardAndPop()
            }
        } message: {
            Text("수정하기 버튼을 누르지 않으면 변경사항이 반영되지 않아요")
        }
    }
}

#Preview {
    ProfileEditView()
}
