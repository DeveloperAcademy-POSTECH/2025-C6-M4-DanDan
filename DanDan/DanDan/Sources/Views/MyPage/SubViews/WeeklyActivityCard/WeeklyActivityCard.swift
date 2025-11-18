//
//  WeeklyActivityCard.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/1/25.
//

import SwiftUI

struct WeeklyActivityCard: View {
    let currentWeekText: String
    let weekDistanceKmIntText: String
    let weekScore: Int
    let teamRank: Int
    let teamName: String

    var body: some View {
        VStack(spacing: 24) {
            // TODO: 컴포넌트화 필요
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("이번 주 활동")
                        .font(.PR.body2)
                        .foregroundColor(.steelBlack)
                    Text(currentWeekText)
                        .font(.PR.caption4)
                        .foregroundColor(.gray3)
                }

                Spacer()

                Image(teamName.lowercased() == "blue" ? "train_L_blue" : "train_L_yellow")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55, height: 55)
            }

            HStack(spacing: 40) {
                VStack(spacing: 12) {
                    Text("거리")
                        .font(.PR.caption4)
                        .foregroundColor(.gray3)
                    Text("\(weekDistanceKmIntText)km")
                        .font(.PR.title2)
                        .foregroundColor(.steelBlack)
                }

                VStack(spacing: 12) {
                    Text("획득점수")
                        .font(.PR.caption4)
                        .foregroundColor(.gray3)
                    Text("\(weekScore)점")
                        .font(.PR.title2)
                        .foregroundColor(.steelBlack)
                }

                VStack(spacing: 12) {
                    Text("팀 내 순위")
                        .font(.PR.caption4)
                        .foregroundColor(.gray3)
                    Text("\(teamRank)위")
                        .font(.PR.title2)
                        .foregroundColor(.steelBlack)
                }
            }
        }
        .padding(.top, 24)
        .padding(.bottom, 32)
        .padding(.leading, 20)
        .padding(.trailing, 24)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.lightGreen)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
}

// #Preview {
//    WeeklyActivityCard(viewModel: MyPageViewModel())
// }
