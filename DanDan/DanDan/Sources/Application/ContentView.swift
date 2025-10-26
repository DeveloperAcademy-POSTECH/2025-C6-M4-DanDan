//
//  ContentView.swift
//  DanDan
//
//  Created by Jay on 10/25/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var navigationManager = NavigationManager.shared
    
    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            navigationManager.getRootView()
                .navigationDestination(for: AppDestination.self) { destination in
                    destination.view()
            }
        }
    }
}

#Preview {
    ContentView()
}
