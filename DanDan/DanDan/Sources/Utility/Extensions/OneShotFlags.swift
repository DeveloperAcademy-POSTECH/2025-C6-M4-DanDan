//
//  OneShotFlags.swift
//  DanDan
//
//  Created by soyeonsoo on 11/8/25.
//

import Foundation

enum OneShotKey {
    static let seenTeamAssignment = "seen_team_assignment"
}

extension UserDefaults {
    var hasSeenTeamAssignment: Bool {
        get { bool(forKey: OneShotKey.seenTeamAssignment) }
        set { set(newValue, forKey: OneShotKey.seenTeamAssignment) }
    }
}
