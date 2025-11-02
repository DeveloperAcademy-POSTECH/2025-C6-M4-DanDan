//
//  UserManager.swift
//  DanDan
//
//  Created by Jay on 10/27/25.
//

import Foundation

class UserManager: ObservableObject {
    static let shared = UserManager()

    @Published var userInfo: UserInfo
    
    private let userDefaultsKey = "userInfo"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let saved = try? JSONDecoder().decode(UserInfo.self, from: data) {
            self.userInfo = saved
        } else {
            self.userInfo = UserInfo(
                id: UUID(),
                userName: "익명 사용자",
                userVictoryCnt: 0,
                userTotalScore: 0,
                userImage: [],
                rankHistory: []
            )
            save()
        }
    }
    
    /// 유저의 정보를 저장합니다.
    private func save() {
        if let data = try? JSONEncoder().encode(userInfo) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
}
