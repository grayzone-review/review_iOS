//
//  Location.swift
//  Up
//
//  Created by Wonbi on 7/27/25.
//

import CoreLocation

struct Location: Sendable, Hashable {
    let lat: Double
    let lng: Double
    
    static var `default`: Location {
        .init(lat: 37.5665, lng: 126.9780)
    }
}

extension CLLocationCoordinate2D {
    func toDomain() -> Location {
        .init(lat: latitude, lng: longitude)
    }
}
