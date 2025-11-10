//
//  AccountSettingSection.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/5/25.
//

import SwiftUI

struct AccountSettingSection: View {
    let onTapLogout: () -> Void
    
    init(onTapLogout: @escaping () -> Void = {}) {
        self.onTapLogout = onTapLogout
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "계정")
            NavRow(title: "로그아웃") {
                onTapLogout()
            }
        }
    }
}

#Preview {
    AccountSettingSection()
}
