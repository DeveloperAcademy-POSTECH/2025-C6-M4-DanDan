//
//  AppleSignInButton.swift
//  DanDan
//
//  Created by Jay on 11/9/25.
//

import SwiftUI
import AuthenticationServices

// MARK: - Native Apple Sign in Button

struct AppleSignInButton: UIViewRepresentable {
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let v = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        return v
    }
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) { }
}
