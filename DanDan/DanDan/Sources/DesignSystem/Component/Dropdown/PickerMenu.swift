//
//  Picker.swift
//  DanDan
//
//  Created by Jay on 11/3/25.
//

import SwiftUI

struct PickerMenu: View {
    @Binding var selectedOption: String
    let options: [String]

    var body: some View {
        Menu {
            Picker(selection: $selectedOption, label: EmptyView()) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
        } label: {
            ZStack {
                /// 전체 조합을 미리 배치하여 최대 크기 확보 (실무에서 사용되는 트릭)
                /// -> 이 작업을 생략하면, 선택 항목이 바뀔 때마다 레이아웃이 재조정되어 버벅이듯이 보임
                ForEach(options, id: \.self) { option in
                    HStack(spacing: 4) {
                        Text(option)
                            .font(.PR.caption4)
                            .foregroundColor(.darkGreen)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.darkGreen)
                    }
                    .opacity(0)
                }

                HStack(spacing: 4) {
                    Text(selectedOption)
                        .font(.PR.caption4)
                        .foregroundColor(.darkGreen)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.darkGreen)
                }
            }
            .padding(.vertical, 6)
            .padding(.leading, 12)
            .contentShape(Rectangle())
        }
    }
}

struct PickerMenuPreviewWrapper: View {
    @State private var previewOption = "전체"

    var body: some View {
        PickerMenu(
            selectedOption: $previewOption,
            options: ["전체", "우리 팀"]
        )
    }
}

#Preview {
    PickerMenuPreviewWrapper()
}
