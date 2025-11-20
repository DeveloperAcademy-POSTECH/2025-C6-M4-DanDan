//
//  ConqueredButton.swift
//  DanDan
//
//  Created by soyeonsoo on 11/5/25.
//

import SwiftUI

struct ConqueredButton: View {
    let zoneId: Int
    let onConsume: (Int) -> Void   // 탭 시 호출: zoneId 전달
    @ObservedObject private var status = StatusManager.shared
    
    @State private var isVisible = true
    @State private var isFloating = false
    @State private var showScoreLottie = false
    @State private var buttonOpacity: Double = 1.0
    
    private var railAssetName: String {
        TeamAssetProvider.railAssetName(for: status.userStatus.userTeam)
    }
    
    private var scoreLottieName: String {
        TeamAssetProvider.scoreLottieName(for: status.userStatus.userTeam)
    }
    
    var body: some View {
        // 버튼/로띠가 차지할 고정 영역 (부모 HStack 기준 위치가 변하지 않도록)
        let containerSize = CGSize(width: 120, height: 90)

        ZStack {
            if isVisible {
                Button {
                    let fadeDuration: TimeInterval = 0.4
                    showScoreLottie = true
                    withAnimation(.easeInOut(duration: fadeDuration)) {
                        buttonOpacity = 0.0
                        isFloating = false
                    }
                    onConsume(zoneId)
                    DispatchQueue.main.asyncAfter(deadline: .now() + fadeDuration) {
                        isVisible = false
                    }
                } label: {
                    ZStack {
                        Image(railAssetName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 56)
                            .accessibilityLabel(Text("구역 보상 받기"))
                    }
                    .frame(width: containerSize.width, height: containerSize.height)
                    .scaleEffect(isFloating ? 1.18 : 1.0)
                    .shadow(color: .black.opacity(0.3),
                            radius: isFloating ? 10 : 6,
                            x: 0, y: isFloating ? 34 : 26)
                    .opacity(buttonOpacity)
                    .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true),
                               value: isFloating)
                    .onAppear { isFloating = true }
                }
                .buttonStyle(.plain)
                .zIndex(1)
            }

            if showScoreLottie {
                LottieOnceView(name: scoreLottieName)
                    .frame(width: containerSize.width, height: containerSize.height)
                    .allowsHitTesting(false)
                    .zIndex(2)
            }
        }
        .frame(width: containerSize.width, height: containerSize.height)
    }
}
