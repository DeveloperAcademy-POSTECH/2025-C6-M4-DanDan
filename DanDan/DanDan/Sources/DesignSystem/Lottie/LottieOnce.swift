//
//  LottieOnce.swift
//  DanDan
//
//  Created by soyeonsoo on 11/17/25.
//

import Lottie
import SwiftUI

struct LottieOnceView: UIViewRepresentable {
    let name: String
    var contentMode: UIView.ContentMode = .scaleAspectFit
    var holdProgress: CGFloat = 0.99

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: name)
        view.loopMode = .playOnce
        view.contentMode = contentMode
        view.backgroundBehavior = .pauseAndRestore
        view.isUserInteractionEnabled = false
        view.clipsToBounds = true
        view.layer.allowsEdgeAntialiasing = true

        // 0 -> 0.99까지만 재생하고 해당 지점에서 정지 (마지막 프레임이 투명이라서)
        view.play(fromProgress: 0, toProgress: holdProgress, loopMode: .playOnce) { _ in
            view.pause()
        }
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}
