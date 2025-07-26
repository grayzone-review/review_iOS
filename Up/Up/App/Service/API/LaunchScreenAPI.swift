//
//  LaunchScreenAPI.swift
//  Up
//
//  Created by Jun Young Lee on 7/26/25.
//

import Foundation
import Alamofire

/// LaunchScreenAPI 엔드포인트 정의
enum LaunchScreenAPI: Sendable, URLRequestConvertible {
    case tokenReissue(requestBody: RefreshTokenRequest)

    // 기본 서버 URL
    private var baseURL: URL {
        return URL(string: AppConfig.Network.host)!
    }

    // 각 케이스별 HTTP method
    private var method: HTTPMethod {
        switch self {
        case .tokenReissue:
            return .post
        }
    }
    
    // 각 케이스별 경로(Path)
    private var path: String {
        switch self {
        case .tokenReissue:
            return "/api/auth/reissue"
        }
    }

    // `URLRequestConvertible` 프로토콜 요구사항 구현
    func asURLRequest() throws -> URLRequest {
        let components = URLComponents(string: AppConfig.Network.host + path)!

        switch self {
        case let .tokenReissue(body):
            guard let url = components.url else { throw NSError(domain: "Invalid URL", code: -1) }
            var request = try URLRequest(url: url, method: method)
            let params = body.toDictionary()
            request.httpBody = try JSONSerialization.data(withJSONObject: params)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            return request
        }
    }
}
