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
    var overlayColor: Color = .black.opacity(0.35)
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // 아바타 이미지 또는 플레이스홀더
                Group {
                    if let img = image {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                    } else {
                        ZStack {
                            Circle().fill(Color.lightGreen)
                            Image(systemName: "person.fill")
                                .font(.system(size: 52, weight: .regular))
                                .foregroundStyle(.gray4)
                        }
                    }
                }
                .frame(width: diameter, height: diameter)
                .clipShape(Circle())

                // 아래쪽만 덮는 어두운 오버레이 (하단 strip)
                Circle()
                    .fill(overlayColor)
                    .frame(width: diameter, height: diameter)
                    .mask(
                        VStack(spacing: 0) {
                            Spacer()
                            Rectangle().frame(height: overlayHeight)
                        }
                    )

                // 연필 아이콘: 오버레이 중앙에 배치
                Image(systemName: "pencil")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .offset(y: overlayHeight)
            }
            .frame(width: diameter, height: diameter)
            .contentShape(Circle())
            .accessibilityLabel(Text("프로필 이미지 선택"))
        }
        .buttonStyle(.plain)
    }
}
