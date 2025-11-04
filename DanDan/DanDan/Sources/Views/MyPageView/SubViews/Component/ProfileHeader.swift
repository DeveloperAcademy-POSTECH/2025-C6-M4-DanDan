//
//  ProfileHeader.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/2/25.
//

import SwiftUI

struct ProfileHeader: View {
    @ObservedObject var viewModel: MyPageViewModel
    var action: () -> Void
    private let navigationManager = NavigationManager.shared
    
    var body: some View {
        HStack(spacing: 40) {
            Button(action: action) {
                ZStack(alignment: .bottomTrailing) {
                    viewModel.profileImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width * 0.25,
                               height: UIScreen.main.bounds.width * 0.25)
                        .clipShape(Circle())
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: UIScreen.main.bounds.width * 0.08,
                                   height: UIScreen.main.bounds.width * 0.08)
                        
                        Circle()
                            .fill(.darkGreen)
                            .frame(width: UIScreen.main.bounds.width * 0.07,
                                   height: UIScreen.main.bounds.width * 0.07)
                        
                        VStack(spacing: 0) {
                            Image(systemName: "pencil")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .offset(x: 8, y: 0)
                    
                }
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Text(viewModel.displayName)
                    .font(.pretendard(.semiBold, size: 22))
                    .foregroundColor(.steelBlack)
                
                HStack(spacing: 24) {
                    VStack(alignment: .center, spacing: 8) {
                        Text("우승")
                            .font(.PR.caption4)
                            .foregroundColor(.gray3)
                        Text("\(viewModel.winCount)")
                            .font(.PR.title2)
                            .foregroundColor(.steelBlack)
                    }
                    VStack(alignment: .center, spacing: 8) {
                        Text("총 거리")
                            .font(.PR.caption4)
                            .foregroundColor(.gray3)
                        Text(viewModel.totalDistanceKmText)
                            .font(.PR.title2)
                            .foregroundColor(.steelBlack)
                    }
                    VStack(alignment: .center, spacing: 8) {
                        Text("총 점수")
                            .font(.PR.caption4)
                            .foregroundColor(.gray3)
                        Text("\(viewModel.totalScore)")
                            .font(.PR.title2)
                            .foregroundColor(.steelBlack)
                    }
                }
                .padding(.leading, 8)
            }
            Spacer()

        }
        .padding(.leading, 36)
        .padding(.bottom, 45)
        .padding(.top, 60)
    }
}

#Preview {
    ProfileHeader(viewModel: MyPageViewModel()) {
        print("profile edit view")
    }
}
