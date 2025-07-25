//
//  KakaoAPIService.swift
//  Up
//
//  Created by Wonbi on 7/23/25.
//

import Foundation
import CoreLocation

import Dependencies


protocol KakaoAPIService {
    func getCurrentDistrict(lat: Double, lng: Double) async throws -> String
}

private enum KakaoAPIServiceKey: DependencyKey {
    static let liveValue: any KakaoAPIService = DefaultKakaoAPIService(session: AlamofireNetworkSession(interceptor: KakaoAPIInterceptor()))
    static let previewValue: any KakaoAPIService = DefaultKakaoAPIService(session: AlamofireNetworkSession(interceptor: KakaoAPIInterceptor()))
    static var testValue: any KakaoAPIService = MockKakaoAPIService()
}

extension DependencyValues {
    var kakaoAPIService: any KakaoAPIService {
        get { self[KakaoAPIServiceKey.self] }
        set { self[KakaoAPIServiceKey.self] = newValue }
    }
}

/// 위치 권한 요청 및 현재 위치 가져오기 서비스
struct DefaultKakaoAPIService: KakaoAPIService {
    private let session: NetworkSession
    
    init(session: NetworkSession) {
        self.session = session
    }
    
    func getCurrentDistrict(lat: Double, lng: Double) async throws -> String {
        let request = KaKaoAPI.getLegalDistrict(lat: lat, lng: lng)
        let response: RegionResponse = try await session.request(request, as: RegionResponse.self)
        
        return response.toDomain()
    }
}

struct MockKakaoAPIService: KakaoAPIService {
    func getCurrentDistrict(lat: Double, lng: Double) async throws -> String {
        return "서울시 강남구 서초동"
    }
}
