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
    @EnvironmentObject private var nav: NavigationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selected: School? = nil
    
    // MARK: - 저장 이벤트 콜벡 (서버 연결)
    // 가입하기 버튼 탭 -> 선택된 학교 데이터 전달
    var onComplete: ((School) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            TopBarView {
                if !nav.path.isEmpty {
                    nav.pop()
                } else {
                    nav.navigate(to: .profileSetup)
                }
            }
            
            TitleSectionView(title: "학교 선택하기", description: "다니고 있는 학교를 선택해주세요.")
            
            SchoolListSection(selected: $selected)
            
            Spacer()
            
            // MARK: - 가입하기 버튼
            // 여기서 서버 API 호출
            PrimaryButton(
                "가입하기",
                action: {
                    if let s = selected {
                        onComplete?(s)
                    }
                },
                isEnabled: selected != nil,
                horizontalPadding: 20,
                verticalPadding: 8,
                background: .primaryGreen,
                foreground: .white
            )
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// MARK: - 뒤로가기 버튼
private struct TopBarView: View {
    let onBack: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.steelBlack)
                    .padding(8)
                    .contentShape(Rectangle())
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
}

// MARK: - 선택 리스트 전체 컨테이너
private struct SchoolListSection: View {
    @Binding var selected: School?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(School.allCases.enumerated()), id: \.element.id) { index, school in
                
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
            .background(.lightGreen, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? Color.darkGreen : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    SchoolSelectView()
}
