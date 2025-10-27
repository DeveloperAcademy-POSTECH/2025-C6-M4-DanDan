//
//  RankingViewModel.swift
//  DanDan
//
//  Created by Jay on 10/26/25.
//

import Foundation

@MainActor
class RankingViewModel: ObservableObject {
    @Published var conquestStatuses: [ZoneConquestStatus] = []
    
    private let navigationManager = NavigationManager.shared
    
    func updateConquestStatuses(with scores: [ZoneScore]) {
        conquestStatuses = ZoneScore.evaluatePerZone(scores: scores)
    }
    
    func tapMainButton() {
        navigationManager.popToRoot()
    }
}
