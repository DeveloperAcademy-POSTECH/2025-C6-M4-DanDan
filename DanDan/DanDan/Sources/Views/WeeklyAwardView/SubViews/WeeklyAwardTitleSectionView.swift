//
//  WeeklyAwardTitleSectionView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/7/25.
//

import SwiftUI

struct WeeklyAwardTitleSectionView: View {
    var title: String
    var description: String
    
    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.PR.title1)
                .foregroundStyle(.steelBlack)
            
            Text(description)
                .font(.PR.caption3)
                .foregroundStyle(.gray2)
                .lineSpacing(3)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 68)
    }
}
