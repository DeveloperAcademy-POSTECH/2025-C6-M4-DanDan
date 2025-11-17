//
//  TeamAssetProvider.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/16/25.
//

import Foundation

enum TeamAssetProvider {
    private static func normalizedTeam(_ raw: String) -> String {
        raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    static func railAssetName(for teamRaw: String) -> String {
        switch normalizedTeam(teamRaw) {
        case "blue":
            return "rail_blue"
        case "yellow":
            return "rail_yellow"
        default:
            return "rail_brown"
        }
    }
    
    static func scoreLottieName(for teamRaw: String) -> String {
        switch normalizedTeam(teamRaw) {
        case "blue":
            return "lottie_score_blue"
        case "yellow":
            return "lottie_score_yellow"
        default:
            return "lottie_score_blue"
        }
    }
}

