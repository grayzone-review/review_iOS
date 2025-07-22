//
//  LocationService.swift
//  Up
//
//  Created by Wonbi on 7/21/25.
//

import Foundation
import CoreLocation

/// 위치 요청 중 발생할 수 있는 에러
enum LocationError: Error {
    /// 권한 거절됨
    case authorizationDenied
    case authorizationRestricted // 접근 제한 (예: 자녀 보호 등)
    case locationUnavailable     // 위치를 가져올 수 없음
}

/// 위치 권한 요청 및 현재 위치 가져오기 서비스
final class LocationService: NSObject {
    static let shared = LocationService()
    
    private let manager = CLLocationManager()
    
    /// 권한 변경을 기다리는 Continuation
    private var authContinuation: CheckedContinuation<Void, Error>?
    /// 위치를 기다리는 Continuation
    private var locContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    private override init() {
        super.init()
        manager.delegate = self
    }
    
    /// 권한을 요청하고, 승인이면 현재 위치를, 거절이면 에러를 던집니다.
    func requestCurrentLocation() async throws -> CLLocationCoordinate2D {
        let status = manager.authorizationStatus
        
        switch status {
        case .notDetermined:
            // 아직 요청하지 않았으면 권한 요청
            manager.requestWhenInUseAuthorization()
            // 승인이 될 때까지 기다림 (거절 시 에러 throw)
            try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
                authContinuation = cont
            }
            
        case .denied:
            throw LocationError.authorizationDenied
            
        case .restricted:
            throw LocationError.authorizationRestricted
            
        case .authorizedWhenInUse, .authorizedAlways:
            break
            
        @unknown default:
            throw LocationError.authorizationDenied
        }
        
        // 권한이 OK 이면 위치 요청
        return try await withCheckedThrowingContinuation { (cont: CheckedContinuation<CLLocationCoordinate2D, Error>) in
            locContinuation = cont
            manager.requestLocation()
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    // 권한 상태 변경 콜백
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard let cont = authContinuation else { return }
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            cont.resume(returning: ())
        case .denied:
            cont.resume(throwing: LocationError.authorizationDenied)
        case .restricted:
            cont.resume(throwing: LocationError.authorizationRestricted)
        default:
            break
        }
        authContinuation = nil
    }
    
    // 위치 정보 수신 성공
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let cont = locContinuation else { return }
        if let coord = locations.first?.coordinate {
            cont.resume(returning: coord)
        } else {
            cont.resume(throwing: LocationError.locationUnavailable)
        }
        locContinuation = nil
    }
    
    // 위치 정보 수신 실패
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let cont = locContinuation else { return }
        cont.resume(throwing: error)
        locContinuation = nil
    }
}
