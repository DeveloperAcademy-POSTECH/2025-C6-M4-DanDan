//
//  StatusTag.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/2/25.
//

import SwiftUI

struct StatusTag: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(.PR.caption4)
            .foregroundColor(.white1)
            .frame(height: 20)
            .padding(.horizontal, 16)
            .padding(.vertical, 2)
            .background(.primaryGreen)
            .clipShape(Capsule())
    }
}

//#Preview {
//    VStack(spacing: 20) {
//        StatusTag(text: "진행 중")
//    }
//}
