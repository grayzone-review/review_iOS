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

    case companyDetail(id: String)
    case companyFollow(id: String)
    case companyUnfollow(id: String)

    // 기본 서버 URL
    private var baseURL: URL {
        return URL(string: AppConfig.Network.host)!
    }

    // 각 케이스별 HTTP method
    private var method: HTTPMethod {
        switch self {
        case .companyDetail:
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
        case let .companyFollow(id), let .companyUnfollow(id):
            return "/api/companies/\(id)/follows"
        }
    }

    // 각 케이스별 파라미터(JSON body 등)
    private var parameters: Parameters? {
        switch self {
        case .companyDetail:
            return nil
        case .companyFollow:
            return nil
        case .companyUnfollow:
            return nil
        }
    }

    // `URLRequestConvertible` 프로토콜 요구사항 구현
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = try URLRequest(url: url, method: method)

        switch self {
        case .companyDetail:
            return request
        case .companyFollow:
            return request
        case .companyUnfollow:
            return request
        }
    }
}
