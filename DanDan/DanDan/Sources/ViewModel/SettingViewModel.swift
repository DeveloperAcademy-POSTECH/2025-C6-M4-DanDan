//
//  SettingViewModel.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/5/25.
//

import SwiftUI
import UIKit
import Foundation

@MainActor
final class SettingViewModel: ObservableObject {
    private let navigationManager = NavigationManager.shared
    private let statusManager = StatusManager.shared
    private let zoneScoreManager = ZoneScoreManager.shared
    private let userManager = UserManager.shared
    
    func navigate(to destination: AppDestination) {
        navigationManager.navigate(to: destination)
    }

    func goToTermsService() { navigationManager.navigate(to: .termsService) }
    func goToTermsPrivacy() { navigationManager.navigate(to: .termsPrivacy) }

    func openSystemNotificationSettings() {
        guard let url = URL(string: UIApplication.openNotificationSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    /// 설정 화면에서의 로그아웃 시나리오 진입점
    /// 서버 API가 없으므로 로컬 정리 후 로그인 화면으로 전환합니다.
    func logout() {
        SessionLogoutHandler.perform()
    }
}


