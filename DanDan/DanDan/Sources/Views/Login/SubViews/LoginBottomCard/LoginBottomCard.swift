//
//  LoginBottomCard.swift
//  DanDan
//
//  Created by soyeonsoo on 11/6/25.
//

import SwiftUI

struct LoginBottomCard: View {
    let onAppleSignInTapped: () -> Void
    let onGuestLogin: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("환영해요!")
                .font(.PR.title1)
                .foregroundStyle(.steelBlack)
                .padding(.leading, 10)
            
            Text("철길숲을 걸어 구역을 점령하고\n우리 팀을 우승으로 이끌어보세요.")
                .font(.PR.caption3)
                .foregroundStyle(.gray1)
                .lineSpacing(4)
                .padding(.bottom, 18)
                .padding(.leading, 10)
            
            // Apple
            AppleSignInButton()
                .frame(minWidth: 140, idealWidth: .infinity, maxWidth: .infinity, minHeight: 56, maxHeight: 56)
                .cornerRadius(30)
                .onTapGesture { onAppleSignInTapped() }
                .padding(.bottom, -10)
            
            // Guest
            PrimaryButton(
                "게스트로 로그인",
                action: onGuestLogin,
                horizontalPadding: 0,
                verticalPadding: 10,
                background: .primaryGreen,
                foreground: .white
            )
                        
//            // MARK: - Naver
            
//            Button {
//                showSocialAlert = true
//            } label: {
//                HStack(spacing: 10) {
//                    Image("naver_logo")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 20, height: 20)
//                    
//                    Text("네이버 아이디로 로그인")
//                        .font(.PR.body2)
//                        .foregroundColor(.white)
//                }
//                .frame(maxWidth: .infinity, minHeight: 58)
//            }
//            .buttonStyle(FilledCapsuleButtonStyle(fill: .naverGreen, foreground: .white))
//            
//            // MARK: - Kakao
            
//            Button {
//                showSocialAlert = true
//            } label: {
//                HStack(spacing: 10) {
//                    Image("kakao_logo")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 20, height: 20)
//                    
//                    Text("카카오 아이디로 로그인")
//                        .font(.PR.body2)
//                        .foregroundColor(.black)
//                }
//                .frame(maxWidth: .infinity, minHeight: 58)
//            }
//            .buttonStyle(FilledCapsuleButtonStyle(fill: .kakaoYellow, foreground: .black))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 22)
        .padding(.top, 24)
        .background(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(.white.opacity(0.8), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 14)
        )
        .padding(.horizontal, 6)
    }
}
