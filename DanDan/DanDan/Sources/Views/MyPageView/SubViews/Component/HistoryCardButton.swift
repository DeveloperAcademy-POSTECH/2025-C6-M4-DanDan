//
//  HistoryCardButton.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/1/25.
//

import SwiftUI

struct HistoryCardButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                Text("시즌 히스토리")
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
    HistoryCardButton() {
        print("시즌 히스토리 버튼 탭됨")
    }
}
