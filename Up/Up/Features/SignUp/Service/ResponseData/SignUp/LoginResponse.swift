//
//  LoginResponse.swift
//  Up
//
//  Created by Wonbi on 7/9/25.
//

public struct LoginResponse: Codable {
    /// Up 액세스 토큰
    public let accessToken: String
    /// Up 리프레쉬 토큰
    public let refreshToken: String
}
