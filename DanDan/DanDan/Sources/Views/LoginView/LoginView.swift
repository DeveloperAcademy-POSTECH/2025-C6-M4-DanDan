//
//  LoginView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/5/25.
//

import AuthenticationServices
import SwiftUI

struct LoginView: View {
    @State private var showSocialAlert = false
    
    // Callback for guest login (서버 여기로 연결)
    var onGuestLogin: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("환영해요!")
                        .font(.PR.title1)
                        .foregroundStyle(.steelBlack)
                    
                    Text("철길숲을 걸어 구역을 차지하고,\n우리 팀을 우승으로 이끌어보세요!")
                        .font(.PR.caption3)
                        .foregroundStyle(.gray2)
                        .lineSpacing(4)
                }
                
                // Buttons
                VStack(alignment: .leading, spacing: 0) {
                    
                    // MARK: - Apple
                    AppleSignInButton()
                        .frame(minWidth: 140, idealWidth: .infinity, maxWidth: .infinity, minHeight: 56, maxHeight: 56)
                        .cornerRadius(30)
                        .onTapGesture { showSocialAlert = true }
                    
//                    Button {
//                        showSocialAlert = true
//                    } label: {
//                        HStack(spacing: 10) {
//                            Image(systemName: "apple.logo")
//                                .renderingMode(.template)
//                                .font(.system(size: 20))
//                            Text("Sign in with Apple")
//                                .font(.system(size: 19, weight: .bold))
//                        }
//                        .frame(maxWidth: .infinity, minHeight: 58)
//                    }
//                    .buttonStyle(FilledCapsuleButtonStyle(fill: .black, foreground: .white))
                    
//                    // MARK: - Naver
//                    Button {
//                        showSocialAlert = true
//                    } label: {
//                        HStack(spacing: 10) {
//                            Image("naver_logo")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 20, height: 20)
//                            
//                            Text("네이버 아이디로 로그인")
//                                .font(.PR.body2)
//                                .foregroundColor(.white)
//                        }
//                        .frame(maxWidth: .infinity, minHeight: 58)
//                    }
//                    .buttonStyle(FilledCapsuleButtonStyle(fill: .naverGreen, foreground: .white))
//                    
//                    // MARK: - Kakao
//                    Button {
//                        showSocialAlert = true
//                    } label: {
//                        HStack(spacing: 10) {
//                            Image("kakao_logo")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 20, height: 20)
//                            
//                            Text("카카오 아이디로 로그인")
//                                .font(.PR.body2)
//                                .foregroundColor(.black)
//                        }
//                        .frame(maxWidth: .infinity, minHeight: 58)
//                    }
//                    .buttonStyle(FilledCapsuleButtonStyle(fill: .kakaoYellow, foreground: .black))
                    
                    // MARK: - Guest
                    PrimaryButton(
                        "게스트로 로그인",
                        action: { onGuestLogin?() },
                        horizontalPadding: 0,
                        verticalPadding: 10,
                        background: .primaryGreen,
                        foreground: .white,
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
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
        LoginView {
            // guest login tapped
        }
        .previewDisplayName("Login")
    }
}
