//
//  UserManager.swift
//  DanDan
//
//  Created by Jay on 10/27/25.
//

import Foundation

class UserManager {
    static let shared = UserManager()

    private let idkey = "userUUID"
    private let nameKey = "userName"

    var id: String {
        if let saved = UserDefaults.standard.string(forKey: idkey) {
            return saved
        } else {
            let uuid = UUID().uuidString
            UserDefaults.standard.set(uuid, forKey: idkey)
            return uuid
        }
    }
    
    var name: String {
        get {
            UserDefaults.standard.string(forKey: nameKey) ?? "익명 사용자"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: nameKey)
        }
    }
}
