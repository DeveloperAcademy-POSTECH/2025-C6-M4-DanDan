//
//  AvatarEditButton.swift
//  DanDan
//
//  Created by soyeonsoo on 11/5/25.
//

import SwiftUI

struct AvatarEditButton: View {
    let image: UIImage?
    var diameter: CGFloat = 120
    var overlayHeight: CGFloat = 38
    var overlayColor: Color = .darkGreen.opacity(0.8)
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Group {
                    if let img = image {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image("default_avatar")
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: diameter, height: diameter)
                .clipShape(Circle())

                Circle()
                    .fill(overlayColor)
                    .frame(width: diameter, height: diameter)
                    .mask(
                        VStack(spacing: 0) {
                            Spacer()
                            Rectangle().frame(height: overlayHeight)
                        }
                    )

                Image(systemName: "camera.on.rectangle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.lightGreen)
                    .offset(y: overlayHeight)
            }
            .frame(width: diameter, height: diameter)
            .contentShape(Circle())
            .accessibilityLabel(Text("프로필 이미지 선택"))
        }
        .buttonStyle(.plain)
    }
}
