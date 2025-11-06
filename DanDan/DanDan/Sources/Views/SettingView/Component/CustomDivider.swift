//
//  Divider.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/5/25.
//

import SwiftUI

struct CustomDivider: View {
    var body: some View {
        VStack(spacing: 0){
            Divider()
                .frame(height: 1)
                .background(.gray5)
                .padding(.vertical, 16)
        }
    }
}

#Preview {
    CustomDivider()
}
