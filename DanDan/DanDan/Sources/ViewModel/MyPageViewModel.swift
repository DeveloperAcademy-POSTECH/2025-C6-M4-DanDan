//
//  MyPageViewModel.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/2/25.
//

import SwiftUI


@MainActor
class MyPageViewModel: ObservableObject {
    private let navigationManager = NavigationManager.shared

    func tapSeasonHistoryButton() {
        navigationManager.navigate(to: .seasonHistory)
    }

    func tapProfileEditButton() {
        navigationManager.navigate(to: .profileEdit)
    }
}
