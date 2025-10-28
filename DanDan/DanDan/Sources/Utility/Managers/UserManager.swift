//
//  UserManager.swift
//  DanDan
//
//  Created by Jay on 10/27/25.
//

import Foundation

class UserManager {
    static let shared = UserManager()

    @Published var userInfo: UserInfo
    
    private let userDefaultsKey = "userInfo"
    
    // TODO: - 백엔드 연동시 삭제 예정
    init() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let saved = try? JSONDecoder().decode(UserInfo.self, from: data) {
            self.userInfo = saved
        } else {
            self.userInfo = UserInfo(
                id: UUID(),
                userName: "익명 사용자",
                userTeam: "",
                userVictoryCnt: 0,
                userTotalScore: 0,
                userImage: [],
                rankHistory: []
            )
            save()
        }
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(userInfo) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
}
