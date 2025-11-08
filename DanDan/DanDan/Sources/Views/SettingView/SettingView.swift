//
//  SettionView.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/5/25.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    
    private var needsCustomBackButton: Bool {
        if #available(iOS 26.0, *) { return false } else { return true }
    }
    
    var body: some View {
        VStack(spacing: 0) {

            AccountSettingSection()
            
            CustomDivider()

            GeneralSettingSection()
           
            CustomDivider()

            TermsSettingSection()
            
            Spacer()
        }
        .padding(.top, 45)
        .navigationBarBackButtonHidden(needsCustomBackButton)
        .toolbar {
            BackTitleToolbar(title: "환경설정") {dismiss()}
        }
        
    }
}



#Preview {
    SettingView()
}
