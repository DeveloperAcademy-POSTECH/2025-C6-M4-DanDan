//
//  ProfileHeader.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/2/25.
//

import SwiftUI

struct ProfileHeader: View {
    let profileImage: Image
    let displayName: String
    let teamName: String
    let winCount: Int
    let totalScore: Int
    
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 40) {
            Button {
                onTap()
            } label: {
                ZStack(alignment: .bottomTrailing) {
                    profileImage
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: UIScreen.main.bounds.width * 0.25,
                            height: UIScreen.main.bounds.width * 0.25
                        )
                        .clipShape(Circle())

                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(
                            width: UIScreen.main.bounds.width * 0.07,
                            height: UIScreen.main.bounds.width * 0.07
                        )
                        .background(Circle().fill(Color.darkGreen))
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .padding(-1)
                        )
                        .offset(x: 8, y: -2)
                }
            }
            
            // TODO: - 컴포넌트화 필요
            VStack(alignment: .leading, spacing: 24) {
                
                VStack(spacing: 4) {
                    Text(displayName)
                        .font(.pretendard(.semiBold, size: 22))
                        .foregroundColor(.steelBlack)
                        .frame(height: 22)
                    
                    Text("포항시 \(teamName)")
                        .font(.PR.caption4)
                        .foregroundColor(.gray3)
                        .frame(height: 20)
                }

                HStack(spacing: 24) {
                    HStack(spacing: 8) {
                        Text("우승")
                            .font(.PR.caption4)
                            .foregroundColor(.gray3)
                        Text("\(winCount)")
                            .font(.PR.title2)
                            .foregroundColor(.steelBlack)
                    }
                    //                    VStack(alignment: .center, spacing: 8) {
                    //                        Text("총 거리")
                    //                            .font(.PR.caption4)
                    //                            .foregroundColor(.gray3)
                    //                        Text(viewModel.totalDistanceKmText)
                    //                            .font(.PR.title2)
                    //                            .foregroundColor(.steelBlack)
                    //                    }
                    HStack(spacing: 8) {
                        Text("총 점수")
                            .font(.PR.caption4)
                            .foregroundColor(.gray3)
                        Text("\(totalScore)")
                            .font(.PR.title2)
                            .foregroundColor(.steelBlack)
                    }
                }
            }
            Spacer()
        }
        .padding(.leading, 36)
        .padding(.bottom, 45)
        .padding(.top, 60)
    }
}
