//
//  MyPageAPI.swift
//  Up
//
//  Created by Jun Young Lee on 7/24/25.
//

import Foundation
import Alamofire

/// HomeAPI 엔드포인트 정의
enum MyPageAPI: Sendable, URLRequestConvertible {
    case editUser(requestBody: EditUserRequest)
    case report(requestBody: ReportRequest)
    case resign(requestBody: ResignRequest)
    case signOut(requestBody: ResignRequest)

    // 기본 서버 URL
    private var baseURL: URL {
        return URL(string: AppConfig.Network.host)!
    }

    // 각 케이스별 HTTP method
    private var method: HTTPMethod {
        switch self {
        case .editUser:
            return .put
        case .report:
            return .post
        case .resign:
            return .delete
        case .signOut:
            return .post
        }
    }
    
    // 각 케이스별 경로(Path)
    private var path: String {
        switch self {
        case .editUser, .resign:
            return "/api/users/me"
        case .report:
            return "/api/reports"
        case .signOut:
            return "/api/auth/logout"
        }
    }

    // `URLRequestConvertible` 프로토콜 요구사항 구현
    func asURLRequest() throws -> URLRequest {
        var components = URLComponents(string: AppConfig.Network.host + path)!

        switch self {
        case let .editUser(body):
            guard let url = components.url else { throw NSError(domain: "Invalid URL", code: -1) }
            var request = try URLRequest(url: url, method: method)
            let params = body.toDictionary()
            request.httpBody = try JSONSerialization.data(withJSONObject: params)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            return request
        case let .report(body):
            guard let url = components.url else { throw NSError(domain: "Invalid URL", code: -1) }
            var request = try URLRequest(url: url, method: method)
            let params = body.toDictionary()
            request.httpBody = try JSONSerialization.data(withJSONObject: params)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            return request
        case let .resign(body), let .signOut(body):
            guard let url = components.url else { throw NSError(domain: "Invalid URL", code: -1) }
            var request = try URLRequest(url: url, method: method)
            let params = body.toDictionary()
            request.httpBody = try JSONSerialization.data(withJSONObject: params)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            return request
        }
    }
}
