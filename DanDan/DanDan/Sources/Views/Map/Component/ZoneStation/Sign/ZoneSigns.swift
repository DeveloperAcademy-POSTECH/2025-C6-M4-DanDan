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
			.frame(width: 120, height: 120)
	}
}

//#Preview {
//	ZoneSigns(zoneId: 1)
//}
