//
//  SignUpRequest.swift
//  Up
//
//  Created by Wonbi on 7/9/25.
//
/// 회원가입 요청 바디
public struct SignUpRequest: Encodable, Sendable {
    /// 소셜 로그인 후 받은 토큰
    public let oauthToken: String

    /// 소셜 로그인 제공자 (apple, kakao)
    public let oauthProvider: OAuthProvider

    /// 우리동네 id (법정동 조회 시 받은 id)
    public let mainRegionId: Int

    /// 관심동네 id 목록 (없으면 빈 배열)
    public let interestedRegionIds: [Int]

    /// 닉네임
    public let nickname: String

    /// 약관 동의 항목 (약관 조회할 때 내려준 `code` 필드)
    public let agreements: [String]

    public init(
        oauthToken: String,
        oauthProvider: OAuthProvider,
        mainRegionId: Int,
        interestedRegionIds: [Int] = [],
        nickname: String,
        agreements: [String]
    ) {
        self.oauthToken = oauthToken
        self.oauthProvider = oauthProvider
        self.mainRegionId = mainRegionId
        self.interestedRegionIds = interestedRegionIds
        self.nickname = nickname
        self.agreements = agreements
    }
}
