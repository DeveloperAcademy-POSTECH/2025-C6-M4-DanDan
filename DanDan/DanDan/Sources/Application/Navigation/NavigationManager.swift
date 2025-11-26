//
//  NavigationManager.swift
//  DanDan
//
//  Created by Jay on 10/25/25.
//

import SwiftUI

@MainActor
class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()
    @Published var root: AppDestination = .main
    @Published var hasCompletedOnboarding: Bool = false

    static let shared = NavigationManager()

    private init() {
        
        // TODO: 배포시 제거 - 테스트를 위한 키체인 제거
//        do {
//            try TokenManager().clearTokens()
//            print("🧹 DEBUG: Keychain cleared for clean testing")
//        } catch {
//            print("⚠️ Failed to clear Keychain: \(error)")
//        }

        setRootView()
    }

    func navigate(to destination: AppDestination) {
        path.append(destination)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func pop(to count: Int) {
        guard path.count >= count else { return }
        path.removeLast(count)
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
    
    /// 현재 네비게이션 스택을 비우고 루트 화면을 교체합니다.
    func replaceRoot(with destination: AppDestination) {
        path = NavigationPath()
        root = destination
    }
    
    /// 앱 시작 시 루트 화면 결정:
    /// - 로그인 O + 팀 배정뷰 아직 안봄 → .teamAssignment
    /// - 로그인 O + 팀 배정뷰 봄 → .main
    /// - 로그인 X → .login
    func setRootView() {
        let tokenManager = TokenManager()
        let isAuthenticated = tokenManager.isAuthenticated()
        
        if isAuthenticated {
            if UserDefaults.standard.hasSeenTeamAssignment {
                self.root = .main
            } else {
                self.root = .teamAssignment
            }
        } else {
            self.root = .login
        }
    }
    
    func getRootView() -> some View {
        return root.view()
    }
}
