//
//  Team.swift
//  DanDan
//
//  Created by Jay on 10/28/25.
//

import Foundation

struct Team: Identifiable, Codable {
    let id: UUID
    let teamName: String
    let teamColor: String
}
