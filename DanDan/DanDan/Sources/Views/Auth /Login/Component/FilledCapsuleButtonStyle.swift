//
//  FilledCapsuleButtonStyle.swift
//  DanDan
//
//  Created by Jay on 11/9/25.
//

import SwiftUI

// MARK: - Button Styles

struct FilledCapsuleButtonStyle: ButtonStyle {
    let fill: Color
    let foreground: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.PR.body2)
            .foregroundStyle(foreground)
            .padding(.horizontal, 16)
            .background(
                Capsule()
                    .fill(fill)
            )
            .overlay {
                Capsule()
                    .strokeBorder(foreground.opacity(0.08), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
