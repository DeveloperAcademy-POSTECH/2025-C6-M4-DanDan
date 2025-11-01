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
    
    // MARK: - Initializer (도메인 모델 -> 뷰 데이터로 매핑)
    /// 실제 모델(UserStatus, UserInfo)을 받아서 UI에 필요한 값만 분리해 저장
    init(status: UserStatus, info: UserInfo) {
        self.ranking = status.rank
        self.userName = info.userName
        
        if let firstData = info.userImage.first,
           let uiImage = UIImage(data: firstData) {
            self.userImage = uiImage
        } else {
            self.userImage = nil
        }
        
        self.userConqueredZone = status.userDailyScore
        self.userTeam = status.userTeam
    }
    
    /// Preview를 위한 편의 init
    init(ranking: Int, userName: String, userImage: UIImage? = nil, userConqueredZone: Int, userTeam: String = "none") {
        self.ranking = ranking
        self.userName = userName
        self.userImage = userImage
        self.userConqueredZone = userConqueredZone
        self.userTeam = userTeam
    }
    
    // TODO: 폰트셋 추가 후 수정
    var body: some View {
        HStack {
            Text("\(ranking)")
                .font(.system(size: 18, weight: .bold))
                .frame(width: 36)
                .padding(.horizontal, 12)
            
            profileImage
            
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
        // TODO: 컬러셋 추가 후 수정
        .background(backgroundColor)
        .cornerRadius(12)
    }
    
    // TODO: 팀명 및 컬러셋 확정 후 수정
    // MARK: - Background Logic by Team
    /// 팀에 따라 랭킹 아이템 배경색을 다르게 지정
    private var backgroundColor: Color {
        switch userTeam.lowercased() {
        case "blue":
            return Color.blue.opacity(0.1)
        case "yellow":
            return Color.yellow.opacity(0.1)
        default:
            return Color.gray.opacity(0.1)
        }
    }
    
    // MARK: - Subview: 유저 프로필 이미지
    
    private var profileImage: some View {
        Group {
            if let uiImage = userImage {
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

//#Preview {
//    VStack(spacing: 8) {
//        RankingItemView(ranking: 8, userName: "소연수", userConqueredZone: 12, userTeam: "blue")
//        RankingItemView(ranking: 9, userName: "김소원", userConqueredZone: 9, userTeam: "blue")
//        RankingItemView(ranking: 10, userName: "허찬욱", userConqueredZone: 7, userTeam: "yellow")
//    }
//    .padding()
//}
