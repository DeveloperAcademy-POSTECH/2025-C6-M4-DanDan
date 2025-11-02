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
                    ForEach(viewModel.completedWeeks) { item in
                        CompletedSeasonCard(item: item)
                    }
                }
            }
        }
    }
}

#Preview {
    SeasonHistoryView()
}
