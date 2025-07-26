//
//  ResignRequest.swift
//  Up
//
//  Created by Jun Young Lee on 7/24/25.
//

/// 리프레쉬 토큰만을 필요로 하는 API Request
struct RefreshTokenRequest: Encodable {
    /// 리프레쉬 토큰
    let refreshToken: String
}
