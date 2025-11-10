//
//  ProfileEditSaveButton.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/8/25.
//

import SwiftUI

struct ProfileEditSaveButton: View {
    @ObservedObject var viewModel: ProfileEditViewModel

    var body: some View {
        PrimaryButton(
            "수정하기",
            action: {
                Task {
                    do {
                        try await viewModel.save()
                    } catch {
                        print("🚨 ProfileEdit save failed:", error)
                    }
                }
            },
            /// 이름 수정 or 이미지 수정/삭제 변경사항 있을 시 버튼 활성화
            isEnabled: viewModel.isSaveEnabled
        )
    }
}
