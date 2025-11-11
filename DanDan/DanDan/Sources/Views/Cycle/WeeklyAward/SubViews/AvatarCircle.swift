//
//  AvatarCircle.swift
//  DanDan
//
//  Created by soyeonsoo on 11/7/25.
//

import SwiftUI

struct AvatarCircle: View {
    let imageName: String
    let size: CGFloat

    var body: some View {
        Group {
            // URL인지 검사 (http 또는 https)
            if imageName.starts(with: "http") {
                AsyncImage(url: URL(string: imageName)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure(_):
                        // 로딩 실패 시 기본 아바타
                        Image("default_avatar")
                            .resizable()
                            .scaledToFill()
                    default:
                        // 로딩 중 상태
                        ProgressView()
                    }
                }
            } else {
                // 로컬 에셋 이미지 사용
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle().stroke(Color.white, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
    }
}
