//
//  profileImage.swift
//  DanDan
//
//  Created by soyeonsoo on 11/2/25.
//

import SwiftUI

struct ProfileImageView: View {
    let image: UIImage?
    let isMyRank: Bool

    var body: some View {
        Group {
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
            }
        }
        .frame(width: isMyRank ? 56 : 48, height: isMyRank ? 56 : 48)
        .clipShape(Circle())
        .overlay(alignment: .topTrailing) {
            if isMyRank {
                    MyRankBadgeView()
                    .offset(x: 3, y: -4)
                }
        }
        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
        .padding(.leading, -12)
    }
}
