//
//  AppDestination.swift
//  DanDan
//
//  Created by Jay on 10/25/25.
//

import SwiftUI

enum AppDestination: Hashable {
    case onboarding
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
    // TODO: 더미데이터 수정 - @MainActor 삭제
    @MainActor
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .onboarding:
            OnboardingView()
        case .main:
            TabBarView()
        case .ranking:
            // TODO: 더미데이터 수정
            RankingView(viewModel: .dummy)
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
