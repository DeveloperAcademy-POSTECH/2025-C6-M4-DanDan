//
//  SchoolListSelection.swift
//  DanDan
//
//  Created by soyeonsoo on 11/19/25.
//

import SwiftUI

enum School: String, CaseIterable, Identifiable {
    case daedongMiddle = "대동중학교"
    //    case pohangSteelMiddle = "포항제철중학교"
    case semyeongHigh = "세명고등학교"
    case pohangIdongHigh = "포항이동고등학교"
    
    var id: String { rawValue }
}

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

/// 선택 리스트 전체 컨테이너
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
