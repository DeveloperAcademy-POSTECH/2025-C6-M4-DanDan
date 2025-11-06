//
//  BackButton.swift
//  DanDan
//
//  Created by soyeonsoo on 11/6/25.
//

import SwiftUI

struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.steelBlack)
                .padding(8)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
