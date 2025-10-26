//
//  RankingView.swift
//  DanDan
//
//  Created by Jay on 10/25/25.
//

import SwiftUI

struct RankingView: View {
    private let navigationManeger = NavigationManager.shared
    
    var body: some View {
        Text("랭킹")
        
        Button {
            navigationManeger.popToRoot()
        } label: {
            Text("홈")
        }
    }
}

#Preview {
    RankingView()
}
