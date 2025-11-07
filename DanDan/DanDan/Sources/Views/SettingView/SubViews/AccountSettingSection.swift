//
//  AccountSettingSection.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/5/25.
//

import SwiftUI

struct AccountSettingSection: View {
    @StateObject private var viewModel = SettingViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "계정")
            NavRow(title: "로그아웃") { viewModel.logout() }
        }
    }
}

#Preview {
    AccountSettingSection()
}
