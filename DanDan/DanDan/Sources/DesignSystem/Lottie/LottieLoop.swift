//
//  LottieLoop.swift
//  DanDan
//
//  Created by 김소원 on 11/14/25.
//


import SwiftUI
import Lottie

struct LottieLoopView: UIViewRepresentable {
    let name: String
    var contentMode: UIView.ContentMode = .scaleAspectFill

    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = .loop
        animationView.contentMode = contentMode
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.isUserInteractionEnabled = false
        animationView.clipsToBounds = true
        animationView.layer.allowsEdgeAntialiasing = true
        animationView.play()
        return animationView
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
    }
}
