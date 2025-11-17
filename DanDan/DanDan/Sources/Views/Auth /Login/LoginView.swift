//
//  LoginView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/5/25.
//

import SwiftUI
import Lottie

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    @State private var showSocialAlert = false
    
    var body: some View {
        ZStack {
            LottieLoopView(name: "login_background")
                            .ignoresSafeArea()
            
            LoginBottomCard(
                onAppleSignInTapped: { showSocialAlert = true }, onGuestLogin: { viewModel.tapGuestLoginButton() }
            )
            
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 30)
        }
        .alert("소셜 로그인 준비중", isPresented: $showSocialAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("테스트 버전이라 게스트로 로그인만 가능해요")
        }
    }
}

// MARK: - Preview

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .previewDisplayName("Login")
    }
}
