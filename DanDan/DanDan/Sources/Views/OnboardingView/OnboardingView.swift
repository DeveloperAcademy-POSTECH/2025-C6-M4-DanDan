//
//  OnboardingView.swift
//  DanDan
//
//  Created by Jay on 10/25/25.
//

import SwiftUI

struct OnboardingView: View {
    private let navigationManager = NavigationManager.shared
    
    var body: some View {
        Button {
            navigationManager.replaceRoot(with: .main)
        } label: {
            Text("온보딩")
        }
    }
}

#Preview {
    OnboardingView()
}
