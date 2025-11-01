//
//  NavigationCardButton.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/1/25.
//

import SwiftUI

struct NavigationCardButton: View {
    var cardTitle: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                Text(cardTitle)
                    .font(.PR.body2)
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.black)
                    .font(.system(size: 16, weight: .medium))
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: .secondarySystemBackground))
            )
        }
        .padding(.horizontal, 20)
    }
}


#Preview {
    NavigationCardButton(cardTitle: "시즌 히스토리") {
        print("시즌 히스토리 버튼 탭됨")
    }
}
