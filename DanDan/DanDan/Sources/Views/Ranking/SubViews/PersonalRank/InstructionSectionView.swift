//
//  InstructionSectionView.swift
//  DanDan
//
//  Created by Jay on 11/3/25.
//

import SwiftUI

struct InstructionSectionView: View {
    @State private var selected = "전체"
    
    var body: some View {
        HStack {
            Text("개인랭킹")
                .font(.PR.title1)

            Spacer()

            PickerMenu(
                selectedOption: $selected,
                options: ["전체", "우리 팀"]
            )
        }
    }
}

#Preview {
    InstructionSectionView()
}
