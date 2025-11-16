//
//  MapScreenViewModel.swift
//  DanDan
//
//  Created by Jay on 11/8/25.
//

import Combine
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
    
    /// D-Day 값 (0이면 D-Day, 양수면 D-n)
    @Published var dday: Int = 0
    
    private var ddayCancellable: AnyCancellable?
        
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

// MARK: - D-Day logic
extension MapScreenViewModel {

    /// today ~ period.endDate까지 남은 일수
    private func computeDaysRemaining(now: Date = Date(), period: ConquestPeriod) -> Int {
        let cal = Calendar.current
        let todayStartOfDay = cal.startOfDay(for: now)
        let endOfWeek = cal.startOfDay(for: period.endDate)
        return max(
            0,
            cal.dateComponents([.day], from: todayStartOfDay, to: endOfWeek).day ?? 0
        )
    }

    var ddayText: String {
        dday == 0 ? "D-Day" : "D-\(dday)"
    }

    /// 타이머를 시작해서 1분마다 남은 일수 체크 + 종료 시점에 WeeklyAward로 전환
    func startDDayTimer(period: ConquestPeriod, now: @escaping () -> Date = { Date() }) {
        ddayCancellable?.cancel()

        ddayCancellable = Timer
            .publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }

                let remaining = self.computeDaysRemaining(now: now(), period: period)

                // 점령전이 끝나면 WeeklyAwardView로 이동
                if remaining <= 0 {
                    GamePhaseManager.shared.showWeeklyAward = true
                    self.ddayCancellable?.cancel()
                }
            }
    }
}
