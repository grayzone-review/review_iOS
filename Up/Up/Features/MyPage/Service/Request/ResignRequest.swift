//
//  ResignRequest.swift
//  Up
//
//  Created by Jun Young Lee on 7/24/25.
//

/// 회원 탈퇴, 로그아웃 API Request
struct ResignRequest: Encodable {
    /// 리프레쉬 토큰
    let refreshToken: String
}
