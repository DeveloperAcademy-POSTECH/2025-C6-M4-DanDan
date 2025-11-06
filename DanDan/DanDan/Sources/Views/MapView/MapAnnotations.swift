//
//  MapAnnotations.swift
//  DanDan
//
//  Created by soyeonsoo on 11/7/25.
//

import SwiftUI
import MapKit

// SwiftUI 버튼을 얹기 위한 MKAnnotation
final class StationAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let zone: Zone
    let statusesForZone: [ZoneConquestStatus]
    
    init(coordinate: CLLocationCoordinate2D, zone: Zone, statusesForZone: [ZoneConquestStatus]) {
        self.coordinate = coordinate
        self.zone = zone
        self.statusesForZone = statusesForZone
    }
}

final class HostingAnnotationView: MKAnnotationView {
    private var host: UIHostingController<AnyView>?
    
    var contentSize: CGSize = .zero {
        didSet {
            self.frame = CGRect(origin: .zero, size: contentSize)
            setNeedsLayout()
        }
    }
    
    func setSwiftUIView<Content: View>(_ view: Content) {
        if host == nil {
            let controller = UIHostingController(rootView: AnyView(view))
            controller.view.backgroundColor = .clear
            controller.view.isUserInteractionEnabled = true
            host = controller
            
            addSubview(controller.view)
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                controller.view.topAnchor.constraint(equalTo: topAnchor),
                controller.view.bottomAnchor.constraint(equalTo: bottomAnchor),
                controller.view.leadingAnchor.constraint(equalTo: leadingAnchor),
                controller.view.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        } else {
            host?.rootView = AnyView(view)
        }
        if self.frame.size == .zero {
            self.frame = CGRect(origin: .zero, size: contentSize)
        }
        isUserInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        host?.view.frame = bounds
    }
    
    // 터치 영역 여유
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let extendedBounds = bounds.insetBy(dx: -18, dy: -18)
        return extendedBounds.contains(point)
    }
}
