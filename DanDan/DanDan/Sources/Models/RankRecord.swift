//
//  RankRecord.swift
//  DanDan
//
//  Created by Jay on 10/28/25.
//

import Foundation

struct RankRecord: Identifiable, Codable {
    var id: UUID = UUID()
    var periodID: UUID
    var startDate: Date
    var endDate: Date
    var rank: Int
    var weekScore: Int
    var distanceKm: Double?
}
