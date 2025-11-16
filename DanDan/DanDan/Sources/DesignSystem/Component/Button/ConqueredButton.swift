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
    
    private var railAssetName: String {
        let team = status.userStatus.userTeam.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch team {
        case "blue":
            return "rail_blue"
        case "yellow":
            return "rail_yellow"
        default:
            return "rail_brown"
        }
    }
    
    var body: some View {
        Group {
            if isVisible {
                Button {
                    isVisible = false
                    onConsume(zoneId)
                } label: {
                    ZStack {
                        Image(railAssetName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 56)
                            .accessibilityLabel(Text("구역 보상 받기"))
                    }
                    .frame(width: 150, height: 160)
                    .contentShape(Rectangle())
                    .contentShape(Rectangle())
                    .scaleEffect(isFloating ? 1.18 : 1.0)
                    .shadow(color: .black.opacity(0.5),
                            radius: isFloating ? 10 : 6,
                            x: 0, y: isFloating ? 34 : 26)
                  
                    // TODO: 눌러서 획득 제거 하기
//                    .overlay(alignment: .top) {
//                        Capsule()
//                            .fill(Color.steelBlack.opacity(0.8))
//                            .frame(width: 100, height: 28)
//                            .overlay(
//                                Text("눌러서 구역 획득!")
//                                    .font(.PR.caption5)
//                                    .foregroundStyle(.white)
//                            )
//                            .padding(.top, 4)
//                    }
//                    .offset(y: isFloating ? -6 : 6)
                    .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true),
                               value: isFloating)
                    .onAppear { isFloating = true }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
