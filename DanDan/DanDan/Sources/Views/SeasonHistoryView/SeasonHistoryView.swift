//
//  SeasonHistoryView.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/1/25.
//

import SwiftUI

struct SeasonHistoryView: View {
    @StateObject private var viewModel = SeasonHistoryViewModel()

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    ActiveSeasonCard(viewModel: viewModel)
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
    }
}
