//
//  InstructionSectionView.swift
//  DanDan
//
//  Created by Jay on 11/3/25.
//

import SwiftUI

struct InstructionSectionView: View {

    @State private var isDropdownExpanded: Bool = false
    @State private var selectedOption: String = "전체"

    let title: String = "개인랭킹"
    let options: [String] = ["전체", "우리팀", "상위 10명"]

    var body: some View {
        HStack {
            Text("개인랭킹")

            Spacer()

            Button {
                withAnimation {
                    isDropdownExpanded.toggle()
                }
            } label: {
                HStack(spacing: 4) {
                    Text(selectedOption)
                        .font(.system(size: 14))
                        .foregroundColor(Color("PointGreen01"))  // 너희 색상 시스템 사용 시
                    Image(systemName: "chevron.down")
                        .resizable()
                        .frame(width: 10, height: 5)
                        .foregroundColor(Color("pointGreen01"))
                        .rotationEffect(.degrees(isDropdownExpanded ? 180 : 0))
                }
            }
        }
        
        if isDropdownExpanded {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(options, id: \.self) { option in
                    Button {
                        selectedOption = option
                        withAnimation {
                            isDropdownExpanded = false
                        }
                    } label: {
                        Text(option)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(6)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    InstructionSectionView()
}
