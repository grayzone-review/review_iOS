//
//  ReviewCommentRequest.swift
//  Up
//
//  Created by Wonbi on 6/6/25.
//

/// 리뷰 댓글 생성 API Request
struct ReviewCommentRequest: Encodable {
    /// 댓글 본문 (200자 제한)
    let comment: String
    /// 비밀글 여부
    let secret: Bool
}
