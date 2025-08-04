//
//  SignUpAPI.swift
//  Up
//
//  Created by Wonbi on 7/9/25.
//


import Foundation

import Alamofire

/// CompanyAPI 엔드포인트 정의
enum SignUpAPI: Sendable, URLRequestConvertible {
    case verifyNickname(VerifyNicknameRequest)
    case terms
    case signUp(SignUpRequest)
    case login(LoginRequset)
    case reissue(ReissueRequest)

    // 기본 서버 URL
    private var baseURL: URL {
        return URL(string: AppConfig.Network.host)!
    }

    // 각 케이스별 HTTP method
    private var method: HTTPMethod {
        switch self {
        case .terms:
            return .get
        case .verifyNickname, .signUp, .login, .reissue:
            return .post
        }
    }

    // 각 케이스별 경로(Path)
    private var path: String {
        switch self {
        case .verifyNickname:
            return "/api/users/nickname-verify"
        case .terms:
            return "/api/auth/terms"
        case .signUp:
            return "/api/auth/signup"
        case .login:
            return "/api/auth/login"
        case .reissue:
            return "/api/auth/reissue"
        }
    }

    // `URLRequestConvertible` 프로토콜 요구사항 구현
    func asURLRequest() throws -> URLRequest {
        let components = URLComponents(string: AppConfig.Network.host + path)!
        var request = try URLRequest(url: components, method: method)
        
        switch self {
        case let .verifyNickname(verifyNicknameRequest):
            try request.setJSONBody(verifyNicknameRequest)
        case .terms:
            break
        case let .signUp(signUpRequest):
            try request.setJSONBody(signUpRequest)
        case let .login(loginRequest):
            try request.setJSONBody(loginRequest)
        case let .reissue(reissueRequest):
            try request.setJSONBody(reissueRequest)
        }
        
        return request
    }
}
