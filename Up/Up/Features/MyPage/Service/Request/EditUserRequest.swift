//
//  EditUserRequest.swift
//  Up
//
//  Created by Jun Young Lee on 7/24/25.
//

/// 유저 정보 수정 API Request
struct EditUserRequest: Encodable {
    /// 우리 동네 id
    let mainRegionId: Int
    /// 관심 동네 id
    let interestedRegionIds: [Int]
    /// 닉네임
    let nickname: String
}
