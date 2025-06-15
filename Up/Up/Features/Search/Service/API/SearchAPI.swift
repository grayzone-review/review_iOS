//
//  SearchAPI.swift
//  Up
//
//  Created by Jun Young Lee on 6/14/25.
//

import Foundation
import Alamofire

/// SearchAPI 엔드포인트 정의
enum SearchAPI: Sendable, URLRequestConvertible {
    case searchedCompanies(keyword: String, latitude: Double, longitude: Double, page: Int, size: Int = 10)
    case proposedCompanies(keyword: String, latitude: Double, longitude: Double, page: Int = 0, size: Int = 10)

    // 기본 서버 URL
    private var baseURL: URL {
        return URL(string: AppConfig.Network.host)!
    }

    // 각 케이스별 HTTP method
    private var method: HTTPMethod {
        switch self {
        case .searchedCompanies:
            return .get
        case .proposedCompanies:
            return .get
        }
    }

    // 각 케이스별 경로(Path)
    private var path: String {
        switch self {
        case .searchedCompanies:
            return "/api/companies/search"
        case .proposedCompanies:
            return "/api/companies/suggestions"
        }
    }

    // `URLRequestConvertible` 프로토콜 요구사항 구현
    func asURLRequest() throws -> URLRequest {
        var components = URLComponents(string: AppConfig.Network.host + path)!
        
        switch self {
        case let .searchedCompanies(keyword, latitude, longitude, page, size): // ?keyword=\(keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)&latitude=\(latitude)&longitude=\(longitude)
            components.queryItems = [
                URLQueryItem(name: "keyword", value: keyword),
                URLQueryItem(name: "latitude", value: "\(latitude)"),
                URLQueryItem(name: "longitude", value: "\(longitude)"),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "size", value: "\(size)")
            ]
            guard let url = components.url else { throw NSError(domain: "Invalid URL", code: -1) }
            let request = try URLRequest(url: url, method: method)
            
            return request
        case let .proposedCompanies(keyword, latitude, longitude, page, size): // ?keyword=\(keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)&latitude=\(latitude)&longitude=\(longitude)
            components.queryItems = [
                URLQueryItem(name: "keyword", value: keyword),
                URLQueryItem(name: "latitude", value: "\(latitude)"),
                URLQueryItem(name: "longitude", value: "\(longitude)"),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "size", value: "\(size)")
            ]
            guard let url = components.url else { throw NSError(domain: "Invalid URL", code: -1) }
            let request = try URLRequest(url: url, method: method)

            return request
        }
    }
}
