//
//  MapScreenViewModel.swift
//  DanDan
//
//  Created by Jay on 11/7/25.
//
import Foundation

@MainActor
class MapScreenViewModel: ObservableObject {
    @Published var teams: [MainMapTeam] = []
    @Published var userDailyScore: Int = 0
    @Published var startDate: String = ""
    @Published var endDate: String = ""
    
    private let service = MainMapInfoService()

    func loadMapInfo() async {
        do {
            let response = try await service.fetchMainMapInfo()
            self.teams = response.data.teams
            self.userDailyScore = response.data.userDailyScore
            self.startDate = response.data.startDate
            self.endDate = response.data.endDate
        } catch {
            print("❌ 맵 정보 불러오기 실패: \(error.localizedDescription)")
        }
    }
}
