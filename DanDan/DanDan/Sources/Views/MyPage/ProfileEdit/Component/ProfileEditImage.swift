//
//  ProfileEditImage.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/8/25.
//

import PhotosUI
import SwiftUI
import UIKit

struct ProfileEditImage: View {
    let image: UIImage?
    let onPickImage: (UIImage) -> Void
    let onRemoveImage: () -> Void
    @State private var selectedItem: PhotosPickerItem?
    @State private var showPicker: Bool = false
    @State private var isShowingDialog = false

    var body: some View {
        VStack(spacing: 0) {
            AvatarEditButton(
                image: image,
                diameter: 120,
                overlayHeight: 38,
                overlayColor: .darkGreen.opacity(0.8)
            ) {
                isShowingDialog = true
            }
            .confirmationDialog(
                "이미지 수정하기",
                isPresented: $isShowingDialog
            ) {
                Button("앨범에서 선택") {
                    showPicker = true
                }
                if image != nil {
                    Button("프로필 사진 삭제", role: .destructive) {
                        onRemoveImage()
                    }
                }
                Button("Cancel", role: .cancel) {
                    isShowingDialog = false
                }
            }
            .photosPicker(isPresented: $showPicker, selection: $selectedItem, matching: .images)
            .onChange(of: selectedItem) { _, newItem in
                guard let item = newItem else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data)
                    {
                        onPickImage(uiImage)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

//#Preview {
//    ProfileEditImage(image: nil, onPickImage: { _ in }, onRemoveImage: {})
//}
