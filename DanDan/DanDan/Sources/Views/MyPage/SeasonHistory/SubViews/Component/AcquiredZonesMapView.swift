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
    /// 하이라이트 선 색상 (팀 컬러)
    let highlightColor: UIColor
    
    // 실제 철길숲 남서쪽과 북동쪽 경계 좌표
    private let bounds = MapBounds(
        southWest: .init(latitude: 35.998605, longitude: 129.316145),
        northEast: .init(latitude: 36.057920, longitude: 129.361197),
        margin: 1.0
    )
    
    final class Coordinator: NSObject, MKMapViewDelegate {
        var highlightedZoneIds: Set<Int> = []
        var highlightColor: UIColor = .subA
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let line = overlay as? ColoredPolyline else {
                return MKOverlayRenderer()
            }
            let renderer = MKPolylineRenderer(overlay: line)
            
            if line.isOutline {
                renderer.strokeColor = .darkGreen
                renderer.lineWidth = 7
                return renderer
            }
            
            if highlightedZoneIds.contains(line.zoneId) {
                renderer.strokeColor = highlightColor
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
        c.highlightColor = highlightColor
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
        
         let center = CLLocationCoordinate2D(
             latitude: (bounds.southWest.latitude + bounds.northEast.latitude) / 2,
             longitude: (bounds.southWest.longitude + bounds.northEast.longitude) / 2
         )

        let camera = MKMapCamera(
            lookingAtCenter: center,
            fromDistance: 9300,
            pitch: 0,
            heading:280
        )
        map.setCamera(camera, animated: false)

        MapElementInstaller.installOverlays(for: zones, on: map)
        
        let colored = map.overlays.compactMap { $0 as? ColoredPolyline }
        let outlines = colored.filter { $0.isOutline }
        let mains    = colored.filter { !$0.isOutline }

        map.removeOverlays(colored)
        map.addOverlays(outlines)
        map.addOverlays(mains)
        
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        context.coordinator.highlightedZoneIds = highlightedZoneIds
        context.coordinator.highlightColor = highlightColor
        
        DispatchQueue.main.async {
            for overlay in uiView.overlays {
                guard let line = overlay as? ColoredPolyline,
                      let renderer = uiView.renderer(for: overlay) as? MKPolylineRenderer else { continue }
                
                if line.isOutline {
                    renderer.strokeColor = .darkGreen
                    renderer.lineWidth = 7
                } else {
                    if highlightedZoneIds.contains(line.zoneId) {
                        renderer.strokeColor = context.coordinator.highlightColor
                        renderer.lineWidth = 5
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
//#Preview("하이라이트 여러 개") {
//    AcquiredZonesMapView(
//        highlightedZoneIds: [1, 3, 5, 7]
//    )
//    .frame(height: 160)
//    .clipShape(RoundedRectangle(cornerRadius: 12))
//    .padding()
//}
//
//#Preview("하이라이트 없음") {
//    AcquiredZonesMapView(
//        highlightedZoneIds: []
//    )
//    .frame(height: 160)
//    .clipShape(RoundedRectangle(cornerRadius: 12))
//    .padding()
//}
//
//#Preview("전체 하이라이트") {
//    // zones가 [Zone] 타입이라면, 실제 zoneId들을 모두 Set으로 만든다
//    let allIds = Set(zones.map { $0.id })
//
//    return AcquiredZonesMapView(
//        highlightedZoneIds: allIds
//    )
//    .frame(height: 160)
//    .clipShape(RoundedRectangle(cornerRadius: 12))
//    .padding()
//}
//
