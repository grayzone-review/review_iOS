//
//  HomeAPI.swift
//  Up
//
//  Created by Jun Young Lee on 7/21/25.
//

import Foundation
import Alamofire

/// HomeAPI 엔드포인트 정의
enum HomeAPI: Sendable, URLRequestConvertible {
    case user
    case popularReviews(latitude: Double, longitude: Double, page: Int, size: Int = 10)
    case mainRegionReviews(latitude: Double, longitude: Double, page: Int, size: Int = 10)
    case interestedRegionReviews(latitude: Double, longitude: Double, page: Int, size: Int = 10)
    case myReviews(page: Int, size: Int = 10)
    case interactedReviews(page: Int, size: Int = 10)
    case followedCompanies(page: Int, size: Int = 10)
    case interactionCounts

    // 기본 서버 URL
    private var baseURL: URL {
        return URL(string: AppConfig.Network.host)!
    }

    // 각 케이스별 HTTP method
    private var method: HTTPMethod {
        switch self {
        case .user:
            return .get
        case .popularReviews:
            return .get
        case .mainRegionReviews:
            return .get
        case .interestedRegionReviews:
            return .get
        case .myReviews:
            return .get
        case .interactedReviews:
            return .get
        case .followedCompanies:
            return .get
        case .interactionCounts:
            return .get
        }
    }
    
    // 각 케이스별 경로(Path)
    private var path: String {
        switch self {
        case .user:
            return "/api/users/me"
        case .popularReviews:
            return "/api/reviews/popular"
        case .mainRegionReviews:
            return "/api/reviews/main-region"
        case .interestedRegionReviews:
            return "/api/reviews/interested-region"
        case .myReviews:
            return "/api/users/me/reviews"
        case .interactedReviews:
            return "/api/users/me/interacted-reviews"
        case .followedCompanies:
            return "/api/users/me/followed-companies"
        case .interactionCounts:
            return "/api/users/me/interaction-counts"
        }
    }

    // `URLRequestConvertible` 프로토콜 요구사항 구현
    func asURLRequest() throws -> URLRequest {
        var components = URLComponents(string: AppConfig.Network.host + path)!

        switch self {
        case let .popularReviews(latitude, longitude, page, size):
            components.queryItems = [
                URLQueryItem(name: "latitude", value: "\(latitude)"),
                URLQueryItem(name: "longitude", value: "\(longitude)"),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "size", value: "\(size)")
            ]
            guard let url = components.url else { throw NSError(domain: "Invalid URL", code: -1) }
            let request = try URLRequest(url: url, method: method)
            
            return request
        case let .mainRegionReviews(latitude, longitude, page, size),
            let .interestedRegionReviews(latitude, longitude, page, size):
            components.queryItems = [
                URLQueryItem(name: "latitude", value: "\(latitude)"),
                URLQueryItem(name: "longitude", value: "\(longitude)"),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "size", value: "\(size)"),
                URLQueryItem(name: "sort", value: "createdAt,desc")
            ]
            guard let url = components.url else { throw NSError(domain: "Invalid URL", code: -1) }
            let request = try URLRequest(url: url, method: method)
            
            return request
        case let .myReviews(page, size),
            let .interactedReviews(page, size),
            let .followedCompanies(page, size):
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "size", value: "\(size)"),
                URLQueryItem(name: "sort", value: "createdAt,desc")
            ]
            guard let url = components.url else { throw NSError(domain: "Invalid URL", code: -1) }
            let request = try URLRequest(url: url, method: method)
            
            return request
        default:
            guard let url = components.url else { throw NSError(domain: "Invalid URL", code: -1) }
            let request = try URLRequest(url: url, method: method)
            
            return request
        }
    }
}
