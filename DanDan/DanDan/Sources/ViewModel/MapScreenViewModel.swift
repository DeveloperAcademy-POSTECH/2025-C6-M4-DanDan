//
//  MapScreenViewModel.swift
//  DanDan
//
//  Created by Jay on 11/8/25.
//

import Foundation

@MainActor
class MapScreenViewModel: ObservableObject {
    @Published var teams: [MainMapTeam] = []
    @Published var zoneStatuses: [ZoneStatus] = []
    @Published var userDailyScore: Int = 0
    @Published var startDate: String = ""
    @Published var endDate: String = ""
    
    /// zoneId → 서버에서 받은 팀 점수 배열 캐시
    @Published var zoneTeamScores: [Int: [ZoneTeamScoreDTO]] = [:]
        
    private let service = MapService()
    
    func loadMapInfo() async {
        do {
            let response = try await service.fetchMainMapInfo()
            self.teams = response.data.teams
            
            self.userDailyScore = response.data.userDailyScore
            self.startDate = response.data.startDate
            self.endDate = response.data.endDate
            
            let zoneStatusesResponse = try await service.fetchZoneStatuses()
            self.zoneStatuses = zoneStatusesResponse
            
            print("\n✅ Zone Statuses Loaded (\(zoneStatusesResponse.count))개:")
            for status in zoneStatusesResponse {
                print("- Zone ID:", status.zoneId, "Leading Team:", status.leadingTeamName ?? "없음")
            }
            
        } catch {
            print("❌ 맵 정보 불러오기 실패: \(error.localizedDescription)")
        }
    }
    
    /// 특정 구역의 팀 점수를 서버에서 받아와 저장
    func loadZoneTeamScores(for zoneId: Int) async {
        if zoneTeamScores[zoneId] != nil { return }
        
        do {
            let data = try await service.fetchZoneTeamScores(zoneId: zoneId)
            zoneTeamScores[zoneId] = data.teamScores
        } catch {
            print("❌ (\(zoneId)) 구역 팀 점수 불러오기 실패: \(error)")
        }
    }
}
