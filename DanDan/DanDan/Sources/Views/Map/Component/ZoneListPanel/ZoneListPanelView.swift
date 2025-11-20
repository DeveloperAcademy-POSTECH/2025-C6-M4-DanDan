//
//  ZoneStatusBottomSheetView.swift
//  DanDan
//
//  Created by Jay on 11/20/25.
//

import SwiftUI

struct ZoneListPanelView: View {
    let zoneStatusDetail: [ZoneStatusDetail]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                ForEach(zoneStatusDetail) { zone in
                    ZoneStatusRowView(zone: zone)
                }
            }
        }
        .frame(width: 263)
        .frame(maxHeight: .infinity)
        
        // TODO: 탭바 위에 리스트 보이게 하기 - 하지만 해피는 지금이 이쁘다 생각함
        .padding(.bottom, 24)
    }
}
