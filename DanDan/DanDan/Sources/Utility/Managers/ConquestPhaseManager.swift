//
//  ConquestPhaseManager.swift
//  DanDan
//
//  Created by soyeonsoo on 11/8/25.
//

import SwiftUI
import Combine

final class GamePhaseManager: ObservableObject {
    static let shared = GamePhaseManager()
    @Published var showWeeklyAward = false
    private init() {}
}
