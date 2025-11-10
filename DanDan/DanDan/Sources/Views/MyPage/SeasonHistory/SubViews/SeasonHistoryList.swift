//
//  SeasonHistoryList.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/4/25.
//

import SwiftUI

struct SeasonHistoryList: View {
    @ObservedObject var viewModel: SeasonHistoryViewModel

    var body: some View {
        LazyVStack(spacing: 20) {
            // 현재 진행 중인 시즌 카드 (없을 수 있음)
            if viewModel.hasCurrentWeek {
                ActiveSeasonCard(viewModel: viewModel)
            }

            // 완료된 시즌 카드 리스트
            ForEach(viewModel.completed, id: \.id) { record in
                CompletedSeasonCard(
                    record: record,
                    label: viewModel.completedWeekLabel(for: record),
                    range: viewModel.completedWeekRange(for: record)
                )
            }
        }
    }
}

#Preview {
    SeasonHistoryList(viewModel: SeasonHistoryViewModel())
}
