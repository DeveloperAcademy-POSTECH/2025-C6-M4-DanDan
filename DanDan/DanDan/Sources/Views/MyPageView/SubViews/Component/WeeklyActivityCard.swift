//
//  WeeklyActivityCard.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/1/25.
//

import SwiftUI

struct WeeklyActivityCard: View {
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("이번 주 활동")
                        .font(.PR.body2)
                    Text("현재: 2025년 가을 4주차")
                        .font(.PR.caption4)
                }

                Spacer()

                Image(systemName: "flag.fill")
            }

            HStack(spacing: 40) {
                VStack(spacing: 12) {
                    Text("거리")
                        .font(.PR.caption4)
                    Text("5km")
                        .font(.PR.title2)
                }
                
                VStack(spacing: 12) {
                    Text("획득점수")
                        .font(.PR.caption4)

                    Text("12점")
                        .font(.PR.title2)
                }
               
                VStack(spacing: 12) {
                    Text("팀 내 순위")
                        .font(.PR.caption4)

                    Text("7위")
                        .font(.PR.title2)
                }
            }
        }
        .padding(.top, 24)
        .padding(.bottom, 32)
        .padding(.leading, 20)
        .padding(.trailing, 24)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.quinary)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
}

#Preview {
    WeeklyActivityCard()
}
