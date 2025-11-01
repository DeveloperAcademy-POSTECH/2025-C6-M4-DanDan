//
//  ProfileHeader.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/2/25.
//

import SwiftUI

struct ProfileHeader: View {
    private let navigationManager = NavigationManager.shared
    
    var body: some View {
        HStack(spacing: 40) {
            Button(action: {
                navigationManager.navigate(to: .profileEdit)
            }){
                ZStack(alignment: .bottomTrailing) {
                    Image("testImage")
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width * 0.25,
                               height: UIScreen.main.bounds.width * 0.25)
                        .clipShape(Circle())
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: UIScreen.main.bounds.width * 0.08,
                                   height: UIScreen.main.bounds.width * 0.08)
                        
                        Circle()
                            .fill(Color.blue)
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
                Text("김소원")
                    .font(.pretendard(.semiBold, size: 22))
//                    .padding(.bottom, 16)
                
                HStack(spacing: 24) {
                    VStack(alignment: .center, spacing: 8) {
                        Text("우승")
                            .font(.PR.caption4)
                        Text("3")
                            .font(.PR.title2)
                    }
                    VStack(alignment: .center, spacing: 8) {
                        Text("총 ??")
                            .font(.PR.caption4)
                        Text("2")
                            .font(.PR.title2)
                    }
                    VStack(alignment: .center, spacing: 8) {
                        Text("총 점수")
                            .font(.PR.caption4)
                        Text("1731")
                            .font(.PR.title2)
                    }
                }
                .padding(.leading, 8)
            }
            Spacer()

        }
        .padding(.leading, 36)
    }
}

#Preview {
    ProfileHeader()
}
