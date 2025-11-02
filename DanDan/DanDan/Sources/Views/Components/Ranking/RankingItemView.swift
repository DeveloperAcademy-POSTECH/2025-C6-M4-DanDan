//
//  RankingItemView.swift
//  DanDan
//
//  Created by soyeonsoo on 10/31/25.
//

import SwiftUI

struct RankingItemView: View {
    var ranking: Int
    var userName: String
    var userImage: UIImage?
    var userConqueredZone: Int
    var userTeam: String
    var backgroundColor: Color
    
    init(data: RankingItemData) {
        self.ranking = data.ranking
        self.userName = data.userName
        self.userImage = data.userImage
        self.userConqueredZone = data.userConqueredZone
        self.userTeam = data.userTeam
        self.backgroundColor = data.backgroundColor
    }
    
    /// Preview를 위한 편의 init
    init(
        ranking: Int,
        userName: String,
        userImage: UIImage? = nil,
        userConqueredZone: Int,
        userTeam: String = "none",
        backgroundColor: Color
    ) {
        self.ranking = ranking
        self.userName = userName
        self.userImage = userImage
        self.userConqueredZone = userConqueredZone
        self.userTeam = userTeam
        self.backgroundColor = backgroundColor
    }
    
    // TODO: 폰트셋 추가 후 수정
    var body: some View {
        HStack {
            Text("\(ranking)")
                .font(.system(size: 18, weight: .bold))
                .frame(width: 36)
                .padding(.horizontal, 12)
            
            ProfileImageView(image: userImage)
            
            Text(userName)
                .font(.system(size: 16))
                .lineLimit(1)
                .padding(.leading, 12)
            
            Spacer()
            
            Text("\(userConqueredZone)")
                .padding(.trailing, 24)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: 353, maxHeight: 78)
        .background(backgroundColor)
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 8) {
        RankingItemView(ranking: 8, userName: "소연수", userConqueredZone: 12, userTeam: "blue", backgroundColor: .blue.opacity(0.1))
        RankingItemView(ranking: 9, userName: "김소원", userConqueredZone: 9, userTeam: "blue", backgroundColor: .blue.opacity(0.1))
        RankingItemView(ranking: 10, userName: "허찬욱", userConqueredZone: 7, userTeam: "yellow", backgroundColor: .yellow.opacity(0.1))
    }
    .padding()
}
