//
//  Main.swift
//  DanDan
//
//  Created by Jay on 10/25/25.
//

import SwiftUI

struct MainView: View {
    private let navigationManager = NavigationManager.shared
    
    var body: some View {
        Button {
            navigationManager.navigate(to: .ranking)
        } label: {
            Text("메인")
        }
    }
}

#Preview {
    MainView()
}
