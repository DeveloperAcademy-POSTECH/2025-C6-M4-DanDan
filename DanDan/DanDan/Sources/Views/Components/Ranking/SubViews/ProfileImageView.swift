//
//  profileImage.swift
//  DanDan
//
//  Created by soyeonsoo on 11/2/25.
//

import SwiftUI

struct ProfileImageView: View {
    let image: UIImage?

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
        .frame(width: 46, height: 46)
        .clipShape(Circle())
        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 2)
    }
}
