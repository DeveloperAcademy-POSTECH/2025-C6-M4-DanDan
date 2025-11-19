//
//  TeamInputView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/5/25.
//

import SwiftUI

enum Region {
    case north
    case south
}

struct TeamInputView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = TeamInputViewModel()
    
    @State private var selected: Region? = nil
    @State private var showConfirm = false
    
    private var needsCustomBackButton: Bool {
        if #available(iOS 26.0, *) { return false } else { return true }
    }
    
    let nickname: String
    let profileImage: UIImage?
    
    var body: some View {
        VStack(alignment: .leading) {
            
            TitleSectionView(
                title: "지역 선택하기",
                description: "내가 거주하고 있는 곳을 선택해주세요."
            )
            
            RegionSelect(selected: $selected)
                .padding(.horizontal, 20)
            
            Spacer()
            
            PrimaryButton(
                "시작하기",
                action: {
                    if selected != nil { showConfirm = true }
                },
                isEnabled: selected != nil,
                horizontalPadding: 20,
                background: .primaryGreen,
                foreground: .white
            )
            .padding(.bottom, 20)
        }
        
        .navigationBarBackButtonHidden(needsCustomBackButton)
        
        // MARK: - Back Button
        .toolbar {
            if needsCustomBackButton {
                ToolbarItem(placement: .topBarLeading) {
                    BackButton { dismiss() }
                }
            }
        }
        
        .alert("정확한 정보를 입력하셨나요?", isPresented: $showConfirm) {
            Button("수정하기", role: .cancel) {}
            
            // MARK: - 가입하기 버튼
            // 여기서 서버 API 호출
            Button("시작하기") {
                if let region = selected {
                    Task {
                        viewModel.userName = nickname
                        viewModel.profileImage = profileImage
                        
                        switch region {
                        case .north:
                            viewModel.teamName = "Blue"
                        case .south:
                            viewModel.teamName = "Yellow"
                        }
                        
                        await viewModel.registerGuest()
                        
                        await MainActor.run {
                            StatusManager.shared.userStatus.userTeam = viewModel.teamName
                        }
                        
                        viewModel.goToTeamAssignment()
                    }
                }
            }
            
        } message: {
            Text("가입 이후에는 정보를 바꿀 수 없어요!")
        }
    }
}

#Preview {
    NavigationStack {
        TeamInputView(
            nickname: "테스트 유저",
            profileImage: nil
        )
    }
}
