//
//  OAuthResult.swift
//  Up
//
//  Created by Wonbi on 7/19/25.
//

struct OAuthResult: Sendable, Equatable {
    let token: String
    let authorizationCode: String?
    let provider: String
    
    init(token: String, authorizationCode: String? = nil, provider: String) {
        self.token = token
        self.authorizationCode = authorizationCode
        self.provider = provider
    }
}
