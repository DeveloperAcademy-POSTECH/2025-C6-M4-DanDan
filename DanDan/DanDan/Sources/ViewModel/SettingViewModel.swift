//
//  SettingViewModel.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/5/25.
//

import SwiftUI
import UIKit

@MainActor
final class SettingViewModel: ObservableObject {
    private let navigationManager = NavigationManager.shared

    func navigate(to destination: AppDestination) {
        navigationManager.navigate(to: destination)
    }

    func goToTermsService() { navigationManager.navigate(to: .termsService) }
    func goToTermsPrivacy() { navigationManager.navigate(to: .termsPrivacy) }

    func openSystemNotificationSettings() {
        guard let url = URL(string: UIApplication.openNotificationSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}


