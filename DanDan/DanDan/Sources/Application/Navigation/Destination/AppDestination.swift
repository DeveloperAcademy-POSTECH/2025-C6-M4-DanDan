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
    case settings
    case termsService
    case termsPrivacy
}

extension AppDestination {
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
            TabBarView()
        case .ranking:
            RankingView()
        case .myPage:
            MyPageView()
        case .seasonHistory:
            SeasonHistoryView()
        case .profileEdit:
            ProfileEditView()
        case .settings:
            SettingView()
        case .termsService:
            ServiceTermsView()
        case .termsPrivacy:
            PrivacyPolicyView()
        }
    }
}
