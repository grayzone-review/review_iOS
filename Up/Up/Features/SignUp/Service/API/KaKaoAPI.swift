//
//  KaKaoAPI.swift
//  Up
//
//  Created by Wonbi on 7/23/25.
//

import Foundation

import Alamofire

/// CompanyAPI 엔드포인트 정의
enum KaKaoAPI: Sendable, URLRequestConvertible {
    case getLegalDistrict(lat: Double, lng: Double)

    // 기본 서버 URL
    private var baseURL: URL {
        return URL(string: AppConfig.Network.host)!
    }

    // 각 케이스별 HTTP method
    private var method: HTTPMethod {
        switch self {
        case .getLegalDistrict:
            return .get
        }
    }

    // 각 케이스별 경로(Path)
    private var path: String {
        switch self {
        case .getLegalDistrict:
            return "/local/geo/coord2regioncode.json"
        }
    }

    // `URLRequestConvertible` 프로토콜 요구사항 구현
    func asURLRequest() throws -> URLRequest {
        var components = URLComponents(string: AppConfig.Network.kakaoMapHost + path)!
        
        switch self {
        case let .getLegalDistrict(lat, lng):
            components.queryItems = [
                URLQueryItem(name: "x", value: "\(lng)"),
                URLQueryItem(name: "y", value: "\(lat)"),
            ]
        }
        
        return try URLRequest(url: components, method: method)
    }
}
