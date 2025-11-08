//
//  LoginView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/5/25.
//

import AuthenticationServices
import SwiftUI

struct LoginView: View {
    private let navigationManager = NavigationManager.shared
    
    @State private var showSocialAlert = false
    
    var body: some View {
        ZStack {
            Image("bg_login")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(edges: .all)
            
            LoginBottomCard(
                onAppleSignInTapped: { showSocialAlert = true }, onGuestLogin: { navigationManager.navigate(to: .profileSetup) }
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

// MARK: - Button Styles

struct GlassCapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.primary)
            .padding(.horizontal, 16)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay {
                Capsule().strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            }
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct FilledCapsuleButtonStyle: ButtonStyle {
    let fill: Color
    let foreground: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.PR.body2)
            .foregroundStyle(foreground)
            .padding(.horizontal, 16)
            .background(
                Capsule()
                    .fill(fill)
            )
            .overlay {
                Capsule()
                    .strokeBorder(foreground.opacity(0.08), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Brand Colors

extension Color {
    static let naverGreen  = Color(red: 0/255,   green: 199/255, blue: 60/255)
    static let kakaoYellow = Color(red: 254/255, green: 229/255, blue: 0/255)
}

// MARK: - Native Apple Sign in Button

struct AppleSignInButton: UIViewRepresentable {
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let v = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        return v
    }
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) { }
}

// MARK: - Preview

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .previewDisplayName("Login")
    }
}
