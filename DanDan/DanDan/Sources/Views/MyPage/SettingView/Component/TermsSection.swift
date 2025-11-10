//
//  TermsSection.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/6/25.
//

import SwiftUI

struct TermsSection: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.PR.body1)
                .foregroundColor(.steelBlack)
            
            Text(text)
                .font(.PR.caption2)
                .foregroundColor(.gray1)
        }
        .padding(.bottom, 32)
    }
}

//#Preview {
//    TermsSection()
//}
