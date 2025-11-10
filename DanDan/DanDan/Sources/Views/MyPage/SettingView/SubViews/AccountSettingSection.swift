//
//  AccountSettingSection.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/5/25.
//

import SwiftUI

struct AccountSettingSection: View {
    @ObservedObject var viewModel: SettingViewModel
    let onTapLogout: (() -> Void)?
    
    init(viewModel: SettingViewModel, onTapLogout: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onTapLogout = onTapLogout
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "계정")
            NavRow(title: "로그아웃") {
                if let onTapLogout {
                    onTapLogout()
                } else {
                    viewModel.logout()
                }
            }
        }
    }
}

#Preview {
    AccountSettingSection(viewModel: SettingViewModel())
}
