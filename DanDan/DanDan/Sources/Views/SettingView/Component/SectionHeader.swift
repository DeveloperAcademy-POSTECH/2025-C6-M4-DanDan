//
//  SectionHeader.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/5/25.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.PR.title2)
                .foregroundColor(.steelBlack)

            Spacer()
        }
        .padding(.bottom, 16)
        .padding(.horizontal, 20)
    }
}

#Preview {
    SectionHeader(title: "제목")
}
