//
//  Zone.swift
//  DanDan
//
//  Created by Jay on 10/28/25.
//

import Foundation

struct Zone: Identifiable, Codable {
    var id: Int { zoneId }
    var zoneId: Int
    var zoneName: String
    var zoneStartPoint: Int
    var zoneEndPoint: Int
    var zoneColor: String
}
