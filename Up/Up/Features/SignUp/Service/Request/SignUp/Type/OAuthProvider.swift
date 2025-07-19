//
//  OAuthProvider.swift
//  Up
//
//  Created by Wonbi on 7/9/25.
//

/// 소셜 로그인 제공자
public enum OAuthProvider: String, Encodable, Sendable {
    case apple
    case kakao
    case none
    
    public init(rawValue: String) {
        switch rawValue {
        case "apple": self = .apple
        case "kakao": self = .kakao
        default: self = .none
        }
    }
}
