//
//  Main.swift
//  DanDan
//
//  Created by Jay on 10/25/25.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    
    var body: some View {
        Button {
            viewModel.tapRankingButton()
        } label: {
            Text("메인")
        }
    }
}

#Preview {
    MainView()
}
