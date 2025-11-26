//
//  NavRow.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/5/25.
//

import SwiftUI

struct NavRow: View {
    let title: String
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 0) {
                Text(title)
                    .font(.PR.body3)
                    .foregroundColor(.gray1)
                    .padding(.vertical, 9)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray3)
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        NavRow(title: "로그아웃") {
            print("로그아웃 탭")
        }

        NavRow(title: "알림 설정") {
            print("알림 설정 탭")
        }

        NavRow(title: "개인정보 처리방침") {
            print("개인정보 처리방침 탭")
        }
    }
    .background(Color.white)
}
