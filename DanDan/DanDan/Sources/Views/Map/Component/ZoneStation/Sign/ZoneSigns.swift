//
//  ZoneSigns.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/16/25.
//

import SwiftUI

struct ZoneSigns: View {
	let zoneId: Int
	@State private var showSheet = false
	@StateObject private var viewModel = MapScreenViewModel()
	
	var body: some View {
		Button {
			showSheet = true
		} label: {
			Image("sign\(zoneId)")
				.resizable()
				.scaledToFit()
				.frame(width: 120, height: 120)
		}
		.buttonStyle(.plain)
		.sheet(isPresented: $showSheet) {
			if let z = zones.first(where: { $0.zoneId == zoneId }) {
				ZoneInfoView(
					zone: z,
					teamScores: viewModel.zoneTeamScores[z.zoneId] ?? []
				)
				.task {
					await viewModel.loadZoneTeamScores(for: z.zoneId)
				}
			} else {
				EmptyView()
			}
		}
	}
}

#Preview {
	ZoneSigns(zoneId: 1)
}
