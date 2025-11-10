//
//  GeneralSettingSection.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/5/25.
//

import SwiftUI

struct GeneralSettingSection: View {
    
    let onTapOpenSystemNotificationSettings: () -> Void
    
    init(onTapOpenSystemNotificationSettings: @escaping () -> Void = {}) {
        self.onTapOpenSystemNotificationSettings = onTapOpenSystemNotificationSettings
    }

    var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "일반")
            NavRow(title: "기기 푸시 알림") {
                onTapOpenSystemNotificationSettings()
            }
        }
    }
}

#Preview {
    GeneralSettingSection()
}
