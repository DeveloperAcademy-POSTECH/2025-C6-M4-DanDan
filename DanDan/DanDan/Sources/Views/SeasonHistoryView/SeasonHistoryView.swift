//
//  SeasonHistoryView.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/1/25.
//

import SwiftUI

struct SeasonHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = SeasonHistoryViewModel()

    private var needsCustomBackButton: Bool {
        if #available(iOS 26.0, *) { return false } else { return true }
    }
    
    var body: some View {
        ScrollView {
            SeasonHistoryList(viewModel: viewModel)
        }
        .onAppear {
            Task { await viewModel.load(page: 1, size: 5) }
        }
        .navigationBarBackButtonHidden(needsCustomBackButton)
        .toolbar {
            BackTitleToolbar(title: "시즌 히스토리") {dismiss()}
        }
    }
}
