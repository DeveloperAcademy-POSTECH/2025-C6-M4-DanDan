//
//  TeamManager.swift
//  DanDan
//
//  Created by Jay on 10/27/25.
//

import SwiftUI

class TeamManager {
    static let shared = TeamManager()
    
    @AppStorage("userTeam") var storedTeamRawValue: String?
    
    @Published var userTeam: TeamType?
    
    init() {
        loadTeam()
    }
    
    func loadTeam() {
        if let raw = storedTeamRawValue,
           let team = TeamType(rawValue: raw) {
            self.userTeam = team
        } else {
            self.userTeam = nil
        }
    }
    
    func assignRandomTeamIfNeeded() {
        guard userTeam == nil else { return }
        let random = TeamType.allCases.randomElement()!
        userTeam = random
        storedTeamRawValue = random.rawValue
    }
}
