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
    case searchedCompanies(keyword: String, latitude: Double, longitude: Double)
    case proposedCompanies(keyword: String, latitude: Double, longitude: Double)

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
        case let .searchedCompanies(keyword, latitude, longitude):
            return "/api/companies/search?keyword=\(keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)&latitude=\(latitude)&longitude=\(longitude)"
        case let .proposedCompanies(keyword, latitude, longitude):
            return "/api/companies/suggestions?keyword=\(keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)&latitude=\(latitude)&longitude=\(longitude)"
        }
    }

    // `URLRequestConvertible` 프로토콜 요구사항 구현
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: AppConfig.Network.host + path)! // appendingPathComponent 메서드가 내부적으로 쿼리 시작을 알리는 물음표를 %3F로 인코딩해버리므로 사용 불가. 별도로 인코딩이 필요한 keyword는 addingPercentEncoding 사용중.
        var request = try URLRequest(url: url, method: method)

        switch self {
        case .searchedCompanies:
            return request
        case .proposedCompanies:
            return request
        }
    }
}
