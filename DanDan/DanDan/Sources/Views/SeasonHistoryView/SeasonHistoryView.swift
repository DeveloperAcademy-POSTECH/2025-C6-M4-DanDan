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
        ScrollView {
            SeasonHistoryList(viewModel: viewModel)
        }
    }
}
