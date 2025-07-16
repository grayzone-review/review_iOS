//
//  LoginRequset.swift
//  Up
//
//  Created by Wonbi on 7/9/25.
//

/// 로그인 요청 바디
public struct LoginRequset: Encodable, Sendable {
    /// 소셜 로그인 후 받은 토큰
    public let oauthToken: String

    /// 소셜 로그인 제공자 (apple, kakao)
    public let oauthProvider: OAuthProvider

    public init(
        oauthToken: String,
        oauthProvider: OAuthProvider
    ) {
        self.oauthToken = oauthToken
        self.oauthProvider = oauthProvider
    }
}
