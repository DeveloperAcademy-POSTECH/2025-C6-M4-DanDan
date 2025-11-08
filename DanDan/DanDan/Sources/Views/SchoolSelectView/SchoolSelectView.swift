//
//  SchoolSelectView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/5/25.
//

import SwiftUI

enum School: String, CaseIterable, Identifiable {
    case daedongMiddle = "대동중학교"
    case pohangSteelMiddle = "포항제철중학교"
    case semyeongHigh = "세명고등학교"
    case pohangIdongHigh = "포항이동고등학교"
    
    var id: String { rawValue }
}

struct SchoolSelectView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SchoolSelectViewModel()
    
    @State private var selected: School? = nil
    @State private var showConfirm = false
    
    private let navigationManager = NavigationManager.shared
    private var needsCustomBackButton: Bool {
        if #available(iOS 26.0, *) { return false } else { return true }
    }
    
    let nickname: String
    let profileImage: UIImage?
    
    // MARK: - 저장 이벤트 콜벡 (서버 연결)
    // 가입하기 버튼 탭 -> 선택된 학교 데이터 전달
    var onComplete: ((School) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            
            TitleSectionView(
                title: "학교 선택하기",
                description: "내가 다니고 있는 학교를 선택해주세요."
            )
            
            SchoolListSection(selected: $selected)
            
            Spacer()
            
            PrimaryButton(
                "시작하기",
                action: {
                    if selected != nil { showConfirm = true }
                },
                isEnabled: selected != nil,
                horizontalPadding: 20,
                verticalPadding: 8,
                background: .primaryGreen,
                foreground: .white
            )
            .padding(.bottom, 24)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        
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
            Button("가입하기") {
                if let school = selected {
                    Task {
                        viewModel.userName = nickname
                        viewModel.profileImage = profileImage
                        
                        switch school {
                        case .daedongMiddle, .pohangSteelMiddle:
                            viewModel.teamName = "Yellow"
                        case .semyeongHigh, .pohangIdongHigh:
                            viewModel.teamName = "Blue"
                        }
                        
                        
                        await viewModel.registerGuest()
                        
                        await MainActor.run {
                            StatusManager.shared.userStatus.userTeam = viewModel.teamName
                        }
                        
                        navigationManager.navigate(to: .teamAssignment)
                    }
                }
            }
            
        } message: {
            Text("가입 이후에는 닉네임과 프로필, 학교를 \n바꿀 수 없어요!")
        }
    }
}

// MARK: - 선택 리스트 전체 컨테이너
private struct SchoolListSection: View {
    @Binding var selected: School?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(School.allCases.enumerated()), id: \.element.id) {
                index,
                school in
                
                SchoolOptionRow(
                    title: school.rawValue,
                    isSelected: selected == school
                ) {
                    selected = school
                }
                .padding(6)
            }
        }
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.lightGreen)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - 각 선택 항목
private struct SchoolOptionRow: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .font(.PR.body3)
                    .foregroundStyle(.steelBlack)
                Spacer()
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                .lightGreen,
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        isSelected ? Color.darkGreen : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

//#Preview {
//    SchoolSelectView()
//}
