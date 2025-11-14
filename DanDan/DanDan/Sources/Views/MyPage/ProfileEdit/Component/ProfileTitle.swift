//
//  ProfileTitle.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/8/25.
//

import SwiftUI

struct ProfileTitle: View {
    var title: String
    var description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            Text(title)
                .font(.PR.title1)
                .foregroundColor(.steelBlack)
                .frame(height: 32)
                .padding(.bottom, 8)

            Text(description)
                .font(.pretendard(.regular, size: 15))
                .foregroundColor(.gray2)
                .frame(height: 22)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 14)
        .padding(.bottom, 5)
        .padding(.horizontal, 20)
    }
}
