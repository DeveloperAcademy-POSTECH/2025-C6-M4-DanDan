//
//  NavigationManager.swift
//  DanDan
//
//  Created by Jay on 10/25/25.
//

import SwiftUI

@MainActor
class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()
    @Published var root: AppDestination = .main
    @Published var hasCompletedOnboarding: Bool = true

    static let shared = NavigationManager()
    
    private init() {
        setRootView()
    }

    func navigate(to destination: AppDestination) {
        path.append(destination)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func pop(to count: Int) {
        guard path.count >= count else { return }
        path.removeLast(count)
    }

    func popToRoot() {
        path = NavigationPath()
    }
    
    func setRootView() {
        if hasCompletedOnboarding {
            self.root = .main
        } else {
            self.root = .onboarding
        }
    }

    func getRootView() -> some View {
        return root.view()
    }
}
