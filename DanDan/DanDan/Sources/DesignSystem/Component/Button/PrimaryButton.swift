//
//  PrimaryButton.swift
//  DanDan
//
//  Created by Jay on 10/30/25.
//

import SwiftUI

struct PrimaryButton: View {

    private let title: String
    private let action: () -> Void
    private let isEnabled: Bool
    private let textPadding: CGFloat
    private let horizontalPadding: CGFloat
    private let verticalPadding: CGFloat
    private let background: Color
    private let foreground: Color

    init(
        _ title: String,
        action: @escaping () -> Void,
        isEnabled: Bool = true,
        textPadding: CGFloat = 16,
        horizontalPadding: CGFloat = 20,
        verticalPadding: CGFloat = 20,
        background: Color = .primaryGreen,
        foreground: Color = .white1
    ) {
        self.title = title
        self.action = action
        self.isEnabled = isEnabled
        self.textPadding = textPadding
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.background = background
        self.foreground = foreground
    }

    var body: some View {
        let currentBackground = isEnabled ? background : Color.lightGreen
        let currentForeground = isEnabled ? foreground : Color.gray5
        
        Button(action: action) {
            Text(title)
                .font(.PR.body2)
                .frame(height: 22)
                .padding(.vertical, textPadding)
                .foregroundColor(currentForeground)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(currentBackground)
                )
                
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .buttonStyle(PlainButtonStyle())
        .allowsHitTesting(isEnabled)
    }
}

#Preview {
    PrimaryButton("PrimaryButton") { }
    PrimaryButton(
        "Disabled",
        action: { },
        isEnabled: false,
        background: .gray.opacity(0.6),
        foreground: .white
    )
}
