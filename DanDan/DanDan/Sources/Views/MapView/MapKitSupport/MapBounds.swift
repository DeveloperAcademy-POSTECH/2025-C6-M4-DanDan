//
//  MapBounds.swift
//  DanDan
//
//  Created by soyeonsoo on 11/9/25.
//

import MapKit

struct MapBounds {
    let southWest: CLLocationCoordinate2D
    let northEast: CLLocationCoordinate2D
    let margin: Double

    var center: CLLocationCoordinate2D {
        .init(
            latitude: (southWest.latitude + northEast.latitude) / 2.0,
            longitude: (southWest.longitude + northEast.longitude) / 2.0
        )
    }

    // 지도에 보여줄 영역 계산
    var region: MKCoordinateRegion {
        let spanLat = abs(northEast.latitude - southWest.latitude) * margin
        let spanLon = abs(northEast.longitude - southWest.longitude) * margin
        return .init(
            center: center,
            span: .init(latitudeDelta: spanLat, longitudeDelta: spanLon)
        )
    }
}
