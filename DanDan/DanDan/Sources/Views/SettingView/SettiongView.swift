//
//  SettionView.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/5/25.
//

import SwiftUI

struct SettingView: View {
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
        
    }
}



#Preview {
    SettingView()
}
