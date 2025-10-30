//
//  UserStatus.swift
//  DanDan
//
//  Created by Jay on 10/28/25.
//

import Foundation

struct UserStatus: Identifiable, Codable {
    var id: UUID
    var userTeam: String
    var userWeekScore: Int
    var userDailyScore: Int
    var zoneCheckeStatus: [Int: Bool]
    
    // Correctly spelled alias for read/write access
    var zoneCheckedStatus: [Int: Bool] {
        get { zoneCheckeStatus }
        set { zoneCheckeStatus = newValue }
    }
    
    var rank: Int
}
 
