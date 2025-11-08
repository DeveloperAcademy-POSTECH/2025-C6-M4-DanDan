//
//  TermsSettingSection.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/5/25.
//

import SwiftUI

struct TermsSettingSection: View {
    @StateObject private var viewModel = SettingViewModel()

    var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "약관")
            
            NavRow(title: "서비스 이용약관") { viewModel.goToTermsService() }

            NavRow(title: "개인정보 처리방침") { viewModel.goToTermsPrivacy() }

        }
    }
}

#Preview {
    TermsSettingSection()
}
