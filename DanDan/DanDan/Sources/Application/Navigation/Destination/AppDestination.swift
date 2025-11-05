//
//  AppDestination.swift
//  DanDan
//
//  Created by Jay on 10/25/25.
//

import SwiftUI

enum AppDestination: Hashable {
    case onboarding
    case login
    case profileSetup
    case schoolSelection
    case main
    case ranking
    case myPage
    case seasonHistory
    case profileEdit
}

extension AppDestination {
    // TODO: 더미데이터 수정 - @MainActor 삭제
    @MainActor
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .onboarding:
            OnboardingView()
        case .login:
            LoginView()
        case .profileSetup:
            ProfileSetupView()
        case .schoolSelection:
            SchoolSelectView()
        case .main:
            MainView()
        case .ranking:
            // TODO: 더미데이터 수정
            RankingView(viewModel: .dummy)
        case .myPage:
            MyPageView()
        case .seasonHistory:
            SeasonHistoryView()
        case .profileEdit:
            ProfileEditView()
        }
    }
}
