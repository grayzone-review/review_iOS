//
//  LegalDistrictsAPI.swift
//  Up
//
//  Created by Wonbi on 7/14/25.
//

import Foundation

import Alamofire

/// CompanyAPI 엔드포인트 정의
enum LegalDistrictsAPI: Sendable, URLRequestConvertible {
    case legalDistricts(keyword: String, page: Int)

    // 기본 서버 URL
    private var baseURL: URL {
        return URL(string: AppConfig.Network.host)!
    }

    // 각 케이스별 HTTP method
    private var method: HTTPMethod {
        switch self {
        case .legalDistricts:
            return .get
        }
    }

    // 각 케이스별 경로(Path)
    private var path: String {
        switch self {
        case .legalDistricts:
            return "/api/legal-districts"
        }
    }

    // `URLRequestConvertible` 프로토콜 요구사항 구현
    func asURLRequest() throws -> URLRequest {
        var components = URLComponents(string: AppConfig.Network.host + path)!
        
        switch self {
        case let .legalDistricts(keyword, page):
            components.queryItems = [
                URLQueryItem(name: "keyword", value: "\(keyword)"),
                URLQueryItem(name: "page", value: "\(page)"),
            ]
        }
        
        let request = try URLRequest(url: components, method: method)
        
        return request
    }
}
