//
//  MainViewModel.swift
//  DanDan
//
//  Created by Jay on 10/26/25.
//

import Foundation

@MainActor
class MainViewModel: ObservableObject {
    private let navigationManager = NavigationManager.shared
    
    func tapRankingButton() {
        navigationManager.navigate(to: .ranking)
    }
}
