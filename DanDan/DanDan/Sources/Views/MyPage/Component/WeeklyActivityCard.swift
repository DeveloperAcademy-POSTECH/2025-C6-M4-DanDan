//
//  WeeklyActivityCard.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/1/25.
//

import SwiftUI

struct WeeklyActivityCard: View {
    @ObservedObject var viewModel: MyPageViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("이번 주 활동")
                        .font(.PR.body2)
                        .foregroundColor(.steelBlack)
                    Text(viewModel.currentWeekText)
                        .font(.PR.caption4)
                        .foregroundColor(.gray3)
                }

                Spacer()

                Image(systemName: "flag.fill")
                    .font(.system(size: 48))
            }

            HStack(spacing: 40) {
                VStack(spacing: 12) {
                    Text("거리")
                        .font(.PR.caption4)
                        .foregroundColor(.gray3)
                    Text("\(viewModel.weekDistanceKmIntText)km")
                        .font(.PR.title2)
                        .foregroundColor(.steelBlack)
                }

                VStack(spacing: 12) {
                    Text("획득점수")
                        .font(.PR.caption4)
                        .foregroundColor(.gray3)
                    Text("\(viewModel.weekScore)점")
                        .font(.PR.title2)
                        .foregroundColor(.steelBlack)
                }

                VStack(spacing: 12) {
                    Text("팀 내 순위")
                        .font(.PR.caption4)
                        .foregroundColor(.gray3)
                    Text("\(viewModel.teamRank)위")
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

#Preview {
    WeeklyActivityCard(viewModel: MyPageViewModel())
}
