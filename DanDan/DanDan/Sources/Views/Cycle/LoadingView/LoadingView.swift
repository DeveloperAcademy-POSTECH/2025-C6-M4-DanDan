//
//  LoadingView.swift
//  DanDan
//
//  Created by Jay on 11/17/25.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        LoadingLottieView(animationName: "lottie_loading")
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
    }
}
