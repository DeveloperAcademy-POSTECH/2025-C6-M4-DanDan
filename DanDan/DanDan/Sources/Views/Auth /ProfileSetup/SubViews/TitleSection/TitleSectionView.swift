//
//  TitleSectionView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/5/25.
//

import SwiftUI

struct TitleSectionView: View {
    var title: String
    var description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.PR.title1)
                .foregroundStyle(.steelBlack)
            
            Text(description)
                .font(.PR.caption3)
                .foregroundStyle(.gray2)
                .lineSpacing(3)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }
}
