//
//  CompletedSeasonCard.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/2/25.
//

import SwiftUI

/// 과거 주간 기록 1장을 표현
struct CompletedSeasonCard: View {
    let record: RankRecord
    let label: String
    let range: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더 (주차 / 기간 / 완료 태그)
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.PR.body2)
                        .foregroundColor(.steelBlack)
                    Text(range)
                        .font(.PR.caption4)
                        .foregroundColor(.gray3)
                }
                Spacer()
                StatusTag(text: "완료")
            }
            .padding(.bottom, 32)

            // 간단 통계
            HStack(spacing: 0) {
                Image(record.teamAtPeriod == "blue" ? "train_R_blue" : "train_R_yellow")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)

                Spacer()

                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("거리")
                            .font(.PR.body4)
                            .foregroundColor(.gray3)
                        Text("\(Int(record.distanceKm ?? 0))km")
                            .font(.PR.title2)
                            .foregroundColor(.steelBlack)
                    }
                    VStack(spacing: 8) {
                        Text("점수")
                            .font(.PR.body4)
                            .foregroundColor(.gray3)
                        Text("\(record.weekScore)점")
                            .font(.PR.title2)
                            .foregroundColor(.steelBlack)
                    }
                    VStack(spacing: 8) {
                        Text("팀 내 순위")
                            .font(.PR.body4)
                            .foregroundColor(.gray3)
                        Text("\(record.rank)위")
                            .font(.PR.title2)
                            .foregroundColor(.steelBlack)
                    }
                }
            }
            .padding(.bottom, 28)

            Text("내가 얻은 구역")
                .font(.PR.body4)
                .foregroundColor(.gray3)
                .padding(.bottom, 8)
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray)
                .frame(height: 160)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.lightGreen)
        )
        .padding(.horizontal, 20)
    }
}

//#Preview {
//    let rr = RankRecord(
//        periodID: UUID(),
//        startDate: Date(),
//        endDate: Date().addingTimeInterval(6*24*3600),
//        rank: 2,
//        weekScore: 100,
//        distanceKm: 7.4
//    )
//    return CompletedSeasonCard(
//        record: rr,
//        label: "2025년 10월 4주차",
//        range: "2025.10.20 ~ 2025.10.26"
//    )
//}
