//
//  TokenData.swift
//  Up
//
//  Created by Wonbi on 7/19/25.
//

struct TokenData: Sendable, Equatable {
    let accessToken: String
    let refreshToken: String
    
    init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    init(from response: LoginResponse) {
        self.accessToken = response.accessToken
        self.refreshToken = response.refreshToken
    }
}


