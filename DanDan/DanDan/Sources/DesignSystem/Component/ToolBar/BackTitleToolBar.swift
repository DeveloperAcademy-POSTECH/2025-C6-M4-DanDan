//
//  BackTitleToolBar.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/8/25.
//

import SwiftUI

public struct BackTitleToolbar: ToolbarContent {
    private let title: String
    private let onBack: () -> Void

    public init(title: String, onBack: @escaping () -> Void) {
        self.title = title
        self.onBack = onBack
    }

    private var needsCustomBackButton: Bool {
        if #available(iOS 26.0, *) { return false } else { return true }
    }

    public var body: some ToolbarContent {
        if needsCustomBackButton {
            ToolbarItem(placement: .topBarLeading) {
                BackButton { onBack() }
            }
        }

        ToolbarItem(placement: .principal) {
            Text(title)
                .font(.PR.title2)
        }
    }
}


//#Preview {
//    BackTitleToolbar()
//}
