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

    func goToTermsService() { navigate(to: .termsService) }
    func goToTermsPrivacy() { navigate(to: .termsPrivacy) }
    func goToTermsLocation() { navigate(to: .termsLocation) }

    func openSystemNotificationSettings() {
        guard let url = URL(string: UIApplication.openNotificationSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}


