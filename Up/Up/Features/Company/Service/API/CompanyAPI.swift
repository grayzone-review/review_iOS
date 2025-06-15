//
//  CompanyAPI.swift
//  Up
//
//  Created by Wonbi on 6/6/25.
//

import Foundation

import Alamofire

/// CompanyAPI 엔드포인트 정의
enum CompanyAPI: Sendable, URLRequestConvertible {
    case companyDetail(id: Int)
    case companyReview(id: Int, page: Int, size: Int = 10)
    case companyFollow(id: Int)
    case companyUnfollow(id: Int)

    // 기본 서버 URL
    private var baseURL: URL {
        return URL(string: AppConfig.Network.host)!
    }

    // 각 케이스별 HTTP method
    private var method: HTTPMethod {
        switch self {
        case .companyDetail:
            return .get
        case .companyReview:
            return .get
        case .companyFollow:
            return .post
        case .companyUnfollow:
            return .delete
        }
    }

    // 각 케이스별 경로(Path)
    private var path: String {
        switch self {
        case let .companyDetail(id):
            return "/api/companies/\(id)"
        case let .companyReview(id, _, _):
            return "/api/companies/\(id)/reviews"
        case let .companyFollow(id), let .companyUnfollow(id):
            return "/api/companies/\(id)/follows"
        }
    }

    // `URLRequestConvertible` 프로토콜 요구사항 구현
    func asURLRequest() throws -> URLRequest {
        var components = URLComponents(string: AppConfig.Network.host + path)!

        switch self {
        case .companyDetail:
            guard let url = components.url else { throw NSError(domain: "Invalid URL", code: -1) }
            let request = try URLRequest(url: url, method: method)
            
            return request
        case let .companyReview(_, page, size):
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "size", value: "\(size)")
            ]
            guard let url = components.url else { throw NSError(domain: "Invalid URL", code: -1) }
            let request = try URLRequest(url: url, method: method)
            
            return request
        case .companyFollow:
            guard let url = components.url else { throw NSError(domain: "Invalid URL", code: -1) }
            let request = try URLRequest(url: url, method: method)
            
            return request
        case .companyUnfollow:
            guard let url = components.url else { throw NSError(domain: "Invalid URL", code: -1) }
            let request = try URLRequest(url: url, method: method)
            
            return request
        }
    }
}
