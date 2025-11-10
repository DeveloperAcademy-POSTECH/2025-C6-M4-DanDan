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
        textPadding: CGFloat = 20,
        horizontalPadding: CGFloat = 20,
        verticalPadding: CGFloat = 16,
        background: Color = .primaryGreen,
        foreground: Color = .white,
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
        Button(action: action) {
            Text(title)
                .font(.PR.body2)
                .padding(.top, textPadding)
                .padding(.bottom, textPadding)
                .foregroundColor(foreground)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(background)
                )
                .opacity(isEnabled ? 1.0 : 0.5)
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .buttonStyle(PlainButtonStyle())
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
