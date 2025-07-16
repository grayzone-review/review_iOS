//
//  VerifyNicknameRequest.swift
//  Up
//
//  Created by Wonbi on 7/9/25.
//

public struct VerifyNicknameRequest: Encodable, Sendable {
    /// 중복 조회 하려는 닉네임
    public let nickname: String
    
    public init(nickname: String) {
        self.nickname = nickname
    }
}
