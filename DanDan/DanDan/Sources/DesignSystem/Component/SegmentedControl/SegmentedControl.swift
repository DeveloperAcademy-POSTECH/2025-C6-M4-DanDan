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
     ) 
 }

 - leftTitle / rightTitle : 각 세그먼트의 텍스트
 - isRightSelected : 현재 선택 상태를 바인딩
 */

import SwiftUI

struct SegmentedControl: View {
    @Binding var isRightSelected: Bool
    
    var leftTitle: String
    var rightTitle: String
    
    init(
        leftTitle: String,
        rightTitle: String,
        isRightSelected: Binding<Bool>
    ) {
        self.leftTitle = leftTitle
        self.rightTitle = rightTitle
        self._isRightSelected = isRightSelected
        Self.configureAppearance()
    }

    var body: some View {
        Picker("", selection: Binding(
            get: { isRightSelected },
            set: { newValue in
                isRightSelected = newValue
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

extension SegmentedControl {
    private static func configureAppearance() {
        let appearance = UISegmentedControl.appearance()
        appearance.selectedSegmentTintColor = UIColor.primaryGreen  // 선택된 배경
        appearance.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)   // 선택 텍스트
        appearance.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)     // 비선택 텍스트
    }
}
