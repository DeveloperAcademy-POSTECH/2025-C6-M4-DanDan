//
//  ScoreBoardView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/4/25.
//

import SwiftUI

struct ScoreBoardView: View {
    var leftTeamName: String = "A팀"
    var rightTeamName: String = "B팀"
    var leftTeamScore: Int = 1
    var rightTeamScore: Int = 14
    
    // 합계 기준으로 가로 비율 계산 (합계 0이면 1로 보호)
    private var total: CGFloat {
        max(1, CGFloat(leftTeamScore + rightTeamScore))
    }
    private var leftRatio: CGFloat { CGFloat(leftTeamScore) / total }
    private var rightRatio: CGFloat { CGFloat(rightTeamScore) / total }
    
    var body: some View {
        ZStack {
            // 유리 컨테이너
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(.white.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 14, x: 0, y: 8)
            
            // 안쪽 진행 바 & 라벨
            GeometryReader { geo in
                let inset: CGFloat = 8
                let barHeight: CGFloat = 28
                let barWidth = geo.size.width - inset * 2
                
                // 진행 바
                if leftTeamScore == 0 && rightTeamScore > 0 {
                    UnevenRoundedRectangle(
                        topLeadingRadius: 8, bottomLeadingRadius: 8,
                        bottomTrailingRadius: 8, topTrailingRadius: 8,
                        style: .continuous
                    )
                    .fill(Color.B)
                    .frame(width: barWidth * rightRatio, height: barHeight)
                    .position(x: geo.size.width/2, y: geo.size.height/2)
                } else if rightTeamScore == 0 && leftTeamScore > 0 {
                    UnevenRoundedRectangle(
                        topLeadingRadius: 8, bottomLeadingRadius: 8,
                        bottomTrailingRadius: 8, topTrailingRadius: 8,
                        style: .continuous
                    )
                    .fill(Color.A)
                    .frame(width: barWidth * leftRatio, height: barHeight)
                    .position(x: geo.size.width/2, y: geo.size.height/2)
                } else {
                    HStack(spacing: 2) {
                        UnevenRoundedRectangle(
                            topLeadingRadius: 8, bottomLeadingRadius: 8,
                            bottomTrailingRadius: 0, topTrailingRadius: 0,
                            style: .continuous
                        )
                        .fill(Color.A)
                        .frame(width: barWidth * leftRatio, height: barHeight)
                        
                        UnevenRoundedRectangle(
                            topLeadingRadius: 0, bottomLeadingRadius: 0,
                            bottomTrailingRadius: 8, topTrailingRadius: 8,
                            style: .continuous
                        )
                        .fill(Color.B)
                        .frame(width: barWidth * rightRatio, height: barHeight)
                    }
                    .position(x: geo.size.width/2, y: geo.size.height/2)
                }
                
                // 라벨
                // 0점인 팀은 진행 바, 라벨 모두 사라짐
                HStack {
                    if leftTeamScore == 0 && rightTeamScore == 0 {
                        // 두 팀 다 0점일 때
                        HStack(spacing: 8) {
                            Text(leftTeamName)
                                .font(.PR.caption5)
                                .foregroundStyle(.steelBlack)
                            Text("0")
                                .font(.PR.caption5)
                                .foregroundStyle(.gray1)
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Text("0")
                                    .font(.PR.caption5)
                                    .foregroundStyle(.gray1)
                                Text(rightTeamName)
                                    .font(.PR.caption5)
                                    .foregroundStyle(.steelBlack)
                            }
                            .padding(.trailing, inset)
                        }
                        .padding(.leading, inset)
                    } else {
                        if leftTeamScore > 0 {
                            HStack(spacing: 8) {
                                Text(leftTeamName)
                                    .font(.PR.caption5)
                                    .foregroundStyle(.steelBlack)
                                Text("\(leftTeamScore)")
                                    .font(.PR.caption5)
                                    .foregroundStyle(.gray1)
                            }
                            .padding(.leading, inset)
                        }
                        
                        Spacer()
                        
                        if rightTeamScore > 0 {
                            HStack(spacing: 8) {
                                Text("\(rightTeamScore)")
                                    .font(.PR.caption5)
                                    .foregroundStyle(.gray1)
                                Text(rightTeamName)
                                    .font(.PR.caption5)
                                    .foregroundStyle(.steelBlack)
                            }
                            .padding(.trailing, inset)
                        }
                    }
                }
                .frame(width: barWidth, height: barHeight)
                .position(x: geo.size.width/2, y: geo.size.height/2)
            }
            .padding(4)
        }
        .frame(width: 340, height: 44)
    }
}

#Preview {
    VStack(spacing: 20) {
        ScoreBoardView(leftTeamName: "A팀", rightTeamName: "B팀",
                       leftTeamScore: 1, rightTeamScore: 14)
        ScoreBoardView(leftTeamName: "Blue", rightTeamName: "Yellow",
                       leftTeamScore: 7, rightTeamScore: 8)
        ScoreBoardView(leftTeamName: "A", rightTeamName: "B",
                       leftTeamScore: 0, rightTeamScore: 0)
        ScoreBoardView(leftTeamName: "A", rightTeamName: "B",
                       leftTeamScore: 2, rightTeamScore: 0)
    }
    .padding()
    .background(
        LinearGradient(colors: [.subA50, .subB20], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    )
}
