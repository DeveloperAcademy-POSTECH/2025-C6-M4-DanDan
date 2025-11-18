//
//  LoadingView.swift
//  DanDan
//
//  Created by Jay on 11/17/25.
//

import SwiftUI

struct LoadingView: View {
    @StateObject private var viewModel = LoadingViewModel()
    
    var body: some View {
        ZStack {
            LoadingLottieView(animationName: "loading")
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                viewModel.navigateToWeeklyAward()
            }
        }
    }
}
