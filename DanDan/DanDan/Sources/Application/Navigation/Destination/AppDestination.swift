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
}

extension AppDestination {
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .onboarding:
            OnboardingView()
        case .main:
            MainView()
        case .ranking:
            RankingView()
        case .myPage:
            MyPageView()
        case .seasonHistory:
            SeasonHistoryView()
        case .profileEdit:
            ProfileEditView()
        }
    }
}
