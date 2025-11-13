//
//  AcquiredZonesMapView.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/13/25.
//
//

import MapKit
import SwiftUI

/// 시즌 히스토리 카드 하단의 "내가 얻은 구역" 미니 지도
/// - 주어진 주차 동안 한 번이라도 방문한 구역(`highlightedZoneIds`)을 SubA 색으로 표시한다.
struct AcquiredZonesMapView: UIViewRepresentable {
    /// 하이라이트할 구역 ID 집합 (주차 내 한 번이라도 걸은 구역)
    let highlightedZoneIds: Set<Int>
    
    // 실제 철길숲 남서쪽과 북동쪽 경계 좌표
    private let bounds = MapBounds(
        southWest: .init(latitude: 35.998605, longitude: 129.316145),
        northEast: .init(latitude: 36.057920, longitude: 129.361197),
        margin: 1.35
    )
    
    final class Coordinator: NSObject, MKMapViewDelegate {
        var highlightedZoneIds: Set<Int> = []
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let line = overlay as? ColoredPolyline else {
                return MKOverlayRenderer()
            }
            let renderer = MKPolylineRenderer(overlay: line)
            
            // 외곽선은 사용하지 않음
            if line.isOutline {
                renderer.strokeColor = .darkGreen
                renderer.lineWidth = 0
                return renderer
            }
            
            // 주차 내 방문 이력 존재 시 SubA, 아니면 연한 기본색
            if highlightedZoneIds.contains(line.zoneId) {
                renderer.strokeColor = .subA
            } else {
                renderer.strokeColor = UIColor.primaryGreen
            }
            renderer.lineWidth = 5
            renderer.lineCap = .round
            renderer.lineJoin = .round
            return renderer
        }
    }
    
    func makeCoordinator() -> Coordinator {
        let c = Coordinator()
        c.highlightedZoneIds = highlightedZoneIds
        return c
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        
        map.isScrollEnabled = false
        map.isZoomEnabled = false
        map.isRotateEnabled = false
        map.isPitchEnabled = false
        map.showsUserLocation = false
        
        let config = MKStandardMapConfiguration(elevationStyle: .flat)
        config.pointOfInterestFilter = .excludingAll
        config.showsTraffic = false
        map.preferredConfiguration = config
        
        map.setRegion(bounds.region, animated: false)
        map.delegate = context.coordinator
        
        // 구역 선 설치 (기존 공용 설치 유틸 재사용)
        MapElementInstaller.installOverlays(for: zones, on: map)
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        context.coordinator.highlightedZoneIds = highlightedZoneIds
        
        // 렌더러 갱신
        DispatchQueue.main.async {
            for overlay in uiView.overlays {
                guard let line = overlay as? ColoredPolyline,
                      let renderer = uiView.renderer(for: overlay) as? MKPolylineRenderer else { continue }
                
                if line.isOutline {
                    renderer.strokeColor = .darkGreen
                    renderer.lineWidth = 0
                } else {
                    if highlightedZoneIds.contains(line.zoneId) {
                        renderer.strokeColor = .subA
                    } else {
                        renderer.strokeColor = UIColor.primaryGreen
                    }
                    renderer.lineWidth = 5
                }
                renderer.setNeedsDisplay()
            }
        }
    }
}



