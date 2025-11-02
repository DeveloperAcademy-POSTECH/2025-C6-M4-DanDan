//
//  SegmentedControl.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/2/25.
//

import SwiftUI

struct SegmentedControl: View {
    var leftTitle: String
    var rightTitle: String
    @Binding var isRightSelected: Bool
    var onSelectionChanged: (Bool) -> Void

    var body: some View {
        Picker("", selection: Binding(
            get: { isRightSelected },
            set: { newValue in
                isRightSelected = newValue
                onSelectionChanged(newValue)
            }
        )) {
            Text(leftTitle).tag(false as Bool)
            Text(rightTitle).tag(true as Bool)
        }
        .pickerStyle(.segmented)
        .padding()
//        .padding()
    }
}

#Preview {
    SegmentedControlPreview()
}

private struct SegmentedControlPreview: View {
    @State private var isRightSelected = false
    var body: some View {
        SegmentedControl(leftTitle: "팀", rightTitle: "개인", isRightSelected: $isRightSelected) { newValue in
            print("Selected right: \(newValue)")
        }
        .padding()
    }
}
