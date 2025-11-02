//
//  SegmentedControl.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/2/25.
//

/*
 사용 방법:

 @State private var isRightSelected = false

 var body: some View {
     SegmentedControl(
         leftTitle: "팀",
         rightTitle: "개인",
         isRightSelected: $isRightSelected
     ) { newValue in
         // Handle selection change here
         print("선택된 세그먼트:", newValue ? "개인" : "팀")
     }
 }

 - leftTitle / rightTitle : 각 세그먼트의 텍스트
 - isRightSelected : 현재 선택 상태를 바인딩
 - onSelectionChanged : 선택 변경 시 수행할 동작 콜백
 */

import SwiftUI

struct SegmentedControl: View {
    var leftTitle: String
    var rightTitle: String
    @Binding var isRightSelected: Bool
    var onSelectionChanged: (Bool) -> Void

    init(
        leftTitle: String,
        rightTitle: String,
        isRightSelected: Binding<Bool>,
        onSelectionChanged: @escaping (Bool) -> Void
    ) {
        self.leftTitle = leftTitle
        self.rightTitle = rightTitle
        self._isRightSelected = isRightSelected
        self.onSelectionChanged = onSelectionChanged
    }

    var body: some View {
        Picker("", selection: Binding(
            get: { isRightSelected },
            set: { newValue in
                isRightSelected = newValue
                onSelectionChanged(newValue)
            }
        )) {
            Text(leftTitle).tag(false as Bool)
                .font(.PR.body2)
            Text(rightTitle).tag(true as Bool)
                .font(.PR.body2)
        }

        .pickerStyle(.segmented)
        .padding(.horizontal, 20)
    }
}
