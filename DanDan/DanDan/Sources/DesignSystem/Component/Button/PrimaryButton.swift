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

    init(
        _ title: String,
        action: @escaping () -> Void,
        isEnabled: Bool = true,
        textPadding: CGFloat = 20,
        horizontalPadding: CGFloat = 20,
        verticalPadding: CGFloat = 20
    ) {
        self.title = title
        self.action = action
        self.isEnabled = isEnabled
        self.textPadding = textPadding
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.top, textPadding)
                .padding(.bottom, textPadding)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.primaryGreen)
                )
        }
        .padding(.horizontal)
        .padding(.vertical)
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PrimaryButton("PrimaryButton") {

    }
}
