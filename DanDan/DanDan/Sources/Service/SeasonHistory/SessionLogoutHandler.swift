//
//  SessionLogoutHandler.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/8/25.
//

import Foundation

enum SessionLogoutHandler {
    /// 공용 로그아웃 처리기
    /// - 로컬 토큰/상태 정리 후 네비게이션 루트 전환
    static func perform() {
        // 1) 토큰 삭제 (실패 무시)
        do {
            try TokenManager().clearTokens()
        } catch {
            // ignore
        }

        // 2) 상태 초기화 + 3) 로그인 화면 전환 (메인 스레드)
        Task { @MainActor in
            StatusManager.shared.resetUserStatus()
            StatusManager.shared.resetZoneConquestStatus()
            ZoneScoreManager.shared.resetZoneScore()
            UserManager.shared.reset()

            let navigation = NavigationManager.shared
            navigation.popToRoot()
            navigation.setRootView()
        }
    }
}


