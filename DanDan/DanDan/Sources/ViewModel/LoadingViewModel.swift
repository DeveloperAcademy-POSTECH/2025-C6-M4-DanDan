//
//  LoadingViewModel.swift
//  DanDan
//
//  Created by Jay on 11/18/25.
//

import Foundation

@MainActor
class LoadingViewModel: ObservableObject {
    private let navigationManager = NavigationManager.shared
    
    func navigateToWeeklyAward() {
        navigationManager.navigate(to: .weeklyAward)
    }
}
