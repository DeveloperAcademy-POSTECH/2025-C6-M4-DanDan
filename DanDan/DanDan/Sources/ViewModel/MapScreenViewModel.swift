//
//  MapScreenViewModel.swift
//  DanDan
//
//  Created by Jay on 11/8/25.
//

import Foundation
import MapKit

@MainActor
class MapScreenViewModel: ObservableObject {
    @Published var teams: [MainMapTeam] = []
    @Published var zoneStatuses: [ZoneStatus] = []
    @Published var userDailyScore: Int = 0
    @Published var startDate: String = ""
    @Published var endDate: String = ""
    
    /// zoneId → 서버에서 받은 팀 점수 배열 캐시
    @Published var zoneTeamScores: [Int: [ZoneTeamScoreDTO]] = [:]
    /// UI 바인딩용: 선택된 구역
    @Published var selectedZone: Zone? = nil
        
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
    
    // MARK: - Zone Picking
    /// 드래그 종료 좌표에서 가장 가까운 구역을 찾아 선택하고 점수 프리패치
    func pickNearestZone(to coordinate: CLLocationCoordinate2D, maxDistanceMeters: CLLocationDistance = 70) {
        let target = MKMapPoint(coordinate)
        guard let best = zones.min(by: {
            distance(from: target, toPolylineOf: $0.coordinates) < distance(from: target, toPolylineOf: $1.coordinates)
        }) else { return }
        let bestDistance = distance(from: target, toPolylineOf: best.coordinates)
        guard bestDistance <= maxDistanceMeters else { return }
        selectedZone = best
        Task { await loadZoneTeamScores(for: best.zoneId) }
    }
    
    /// 점과 폴리라인(좌표 배열) 사이의 최단 거리(m)
    private func distance(from p: MKMapPoint, toPolylineOf coords: [CLLocationCoordinate2D]) -> CLLocationDistance {
        guard coords.count >= 2 else { return .greatestFiniteMagnitude }
        var minMeters = CLLocationDistance.greatestFiniteMagnitude
        for i in 0..<(coords.count - 1) {
            let a = MKMapPoint(coords[i])
            let b = MKMapPoint(coords[i + 1])
            let meters = distancePointToSegment(p, a, b)
            if meters < minMeters { minMeters = meters }
        }
        return minMeters
    }
    
    /// 점-선분 최단 거리(m) (MKMapPoint 기반)
    private func distancePointToSegment(_ p: MKMapPoint, _ a: MKMapPoint, _ b: MKMapPoint) -> CLLocationDistance {
        let abx = b.x - a.x
        let aby = b.y - a.y
        let apx = p.x - a.x
        let apy = p.y - a.y
        let ab2 = abx * abx + aby * aby
        if ab2 == 0 {
            return p.distance(to: a)
        }
        let t = max(0, min(1, (apx * abx + apy * aby) / ab2))
        let proj = MKMapPoint(x: a.x + t * abx, y: a.y + t * aby)
        return p.distance(to: proj)
    }
}
