//
//  RegionSelect.swift
//  DanDan
//
//  Created by soyeonsoo on 11/19/25.
//

import SwiftUI

struct RegionSelect: View {    
    @Binding var selected: Region?

    var body: some View {
        Image(
            selected == .north
            ? "north_selected"
            : selected == .south
            ? "south_selected"
            : "pohang_map_base"
        )
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .padding(.top, 50)

            // 보이지 않는 직사각형 버튼들
            .overlay(
                Button { // 북구 버튼
                    selected = .north
                } label: {
                    Rectangle()
                        .fill(Color.clear)
                }
                    .frame(width: 220, height: 190)
                    .offset(x: 0, y: -86)
            )
            .overlay(
                Button { // 남구 버튼
                    selected = .south
                } label: {
                    Rectangle()
                        .fill(Color.clear)
                }
                .frame(width: 320, height: 200)
                .offset(x: 0, y: 110)
            )
    }
}


