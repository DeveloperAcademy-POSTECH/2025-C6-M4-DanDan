//
//  GeneralSettingSection.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/5/25.
//

import SwiftUI

struct GeneralSettingSection: View {
    @StateObject private var viewModel = SettingViewModel()

    var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "일반")
            NavRow(title: "기기 푸시 알림") {
                viewModel.openSystemNotificationSettings()
            }
        }
    }
}

#Preview {
    GeneralSettingSection()
}
