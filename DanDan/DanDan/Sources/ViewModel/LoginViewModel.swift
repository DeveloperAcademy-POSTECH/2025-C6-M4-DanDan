//
//  LoginViewModel.swift
//  DanDan
//
//  Created by Jay on 11/9/25.
//

import Foundation

@MainActor
class LoginViewModel: ObservableObject {
    private let navigationManager = NavigationManager.shared

    /// 프로필 설정 화면으로 이동합니다.
    func tapGuestLoginButton() {
        navigationManager.navigate(to: .profileSetup)
    }
}
