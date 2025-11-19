//
//  ContentView.swift
//  DanDan
//
//  Created by Jay on 10/25/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var navigationManager = NavigationManager.shared
    @StateObject private var gamePhase = GamePhaseManager.shared
    
    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            
            if gamePhase.showWeeklyAward {
                WeeklyAwardView()
            } else {
                navigationManager.getRootView()
                    .navigationDestination(for: AppDestination.self) { $0.view() }
            }
        }
        .task {
            await gamePhase.checkWeeklyAwardCondition()
        }
    }
}

#Preview {
    ContentView()
}
