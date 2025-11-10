//
//  SettionView.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/5/25.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showLogoutAlert: Bool = false
    @StateObject private var viewModel = SettingViewModel()
    
    private var needsCustomBackButton: Bool {
        if #available(iOS 26.0, *) { return false } else { return true }
    }
    
    var body: some View {
        VStack(spacing: 0) {

            AccountSettingSection(onTapLogout: {showLogoutAlert = true})
            
            CustomDivider()

            GeneralSettingSection(
                onTapOpenSystemNotificationSettings: { viewModel.openSystemNotificationSettings() }
            )
           
            CustomDivider()

            TermsSettingSection(
                onTapTermsService: { viewModel.goToTermsService() },
                onTapTermsPrivacy: { viewModel.goToTermsPrivacy() }
            )
            
            Spacer()
        }
        .padding(.top, 45)
        .navigationBarBackButtonHidden(needsCustomBackButton)
        .toolbar {
            BackTitleToolbar(title: "환경설정") {dismiss()}
        }
        .alert("로그아웃 하시겠어요?", isPresented: $showLogoutAlert) {
            Button("뒤로가기", role: .cancel) {}
            Button("로그아웃", role: .destructive) {viewModel.logout()}
        } message: {
            Text("로그아웃 시 다시 정보를 불러올 수 없으며 재가입해야 스틸워크를 사용할 수 있어요.")
        }
        
    }
}



#Preview {
    SettingView()
}
