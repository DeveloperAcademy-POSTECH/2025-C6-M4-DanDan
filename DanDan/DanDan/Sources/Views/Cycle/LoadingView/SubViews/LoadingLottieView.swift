//
//  LoadingLottieView.swift
//  DanDan
//
//  Created by Jay on 11/17/25.
//

import SwiftUI
import Lottie

struct LoadingLottieView: UIViewRepresentable {
    let animationName: String
    
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        
        let animationView = LottieAnimationView(name: animationName)
        animationView.loopMode = .playOnce
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        animationView.play()
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
