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
    case schoolSelection(nickname: String, image: UIImage?)
    case teamAssignment
    case main
    case ranking
    case myPage
    case seasonHistory
    case profileEdit
    case settings
    case termsService
    case termsPrivacy
    case termsLocation
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
        case .schoolSelection(let nickname, let image):
            SchoolSelectView(nickname: nickname, profileImage: image)
        case .teamAssignment:
            TeamAssignmentView()
        case .main:
            TabBarView()
        //            LoginView()
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
        case .termsLocation:
            LocationBasedServiceTermsView()
        }
    }
}
