//
//  ReissueRequest.swift
//  Up
//
//  Created by Wonbi on 7/22/25.
//

public struct ReissueRequest: Encodable, Sendable {
    /// refreshToken
    public let refreshToken: String
    
    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}

