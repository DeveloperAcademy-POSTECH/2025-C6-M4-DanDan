//
//  User.swift
//  DanDan
//
//  Created by Jay on 10/27/25.
//

struct User: Codable {
    let id: String
    var name: String
    var score: Int
    var team: Team
}
