//
//  ServiceTermsView.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/5/25.
//

import SwiftUI

struct ServiceTermsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("서비스 이용약관")
                .font(.PR.title1)
                .foregroundColor(.gray1)
                .padding(.top, 45)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("업데이트 날짜: 2025년 11월")
                        .font(.PR.caption3)
                        .foregroundColor(.gray3)
                        .padding(.top, 8)

                    Text("1. 타이틀")
                        .font(.PR.body2)
                        .foregroundColor(.steelBlack)
                        .padding(.top, 45)

                    Text("내용들어가기")
                        .font(.PR.caption2)
                        .foregroundColor(.gray1)
                        .padding(.top, 24)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
}

#Preview {
    ServiceTermsView()
}
