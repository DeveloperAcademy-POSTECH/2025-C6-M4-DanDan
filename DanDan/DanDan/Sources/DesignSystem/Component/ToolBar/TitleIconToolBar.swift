//
//  TitleIconToolBar.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/8/25.
//

import SwiftUI

public struct TitleIconToolBar: ToolbarContent {
    private let title: String
    private let trailingSystemImage: String
    private let onTapTrailing: () -> Void

    public init(title: String, trailingSystemImage: String, onTapTrailing: @escaping () -> Void) {
        self.title = title
        self.trailingSystemImage = trailingSystemImage
        self.onTapTrailing = onTapTrailing
    }

    public var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(title)
                .font(.PR.title2)
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button(action: onTapTrailing) {
                Image(systemName: trailingSystemImage)
                    .font(.system(size: 17, weight: .medium))
                    .padding(8)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}


//#Preview {
//    TitleIconToolBar()
//}
