//
//  InstructionSectionView.swift
//  DanDan
//
//  Created by Jay on 11/3/25.
//

import SwiftUI

struct InstructionSectionView: View {
    @Binding var selectedFilter: String
    
    var body: some View {
        HStack {
            Text("개인 랭킹")
                .font(.PR.title1)
                .foregroundStyle(.steelBlack)

            Spacer()

            PickerMenu(
                selectedOption: $selectedFilter,
                options: ["전체", "우리 팀"]
            )
        }
    }
}
