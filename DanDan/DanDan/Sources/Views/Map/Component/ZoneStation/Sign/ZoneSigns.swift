//
//  ZoneSigns.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/16/25.
//

import SwiftUI

struct ZoneSigns: View {
	let zoneId: Int
	
	var body: some View {
		Image("sign\(zoneId)")
			.resizable()
			.scaledToFit()
			.frame(width: 80, height: 80)
	}
}

//#Preview {
//	ZoneSigns(zoneId: 1)
//}
