//
//  ReviewService.swift
//  Up
//
//  Created by Wonbi on 6/6/25.
//

import Dependencies

protocol ReviewService {
    func fetchComments(of reviewID: Int, page: Int) async throws -> CommentsBody
    func fetchReplies(of commentID: Int) async throws -> RepliesBody
    func createComment(of reviewID: Int, content: String, isSecret: Bool) async throws -> CommentDTO
    func createReply(of commentID: Int, content: String, isSecret: Bool) async throws -> ReplyDTO
    func createReviewLike(of reviewID: Int) async throws
    func deleteReviewLike(of reviewID: Int) async throws
}

private enum ReviewServiceKey: DependencyKey {
    static let liveValue: any ReviewService = DefaultReviewService(session: AlamofireNetworkSession(interceptor: AuthIDInterceptor()))
    static let previewValue: any ReviewService = DefaultReviewService(session: AlamofireNetworkSession(interceptor: AuthIDInterceptor()))
    static var testValue: any ReviewService = MockReviewService()
}

extension DependencyValues {
    var reviewService: any ReviewService {
        get { self[ReviewServiceKey.self] }
        set { self[ReviewServiceKey.self] = newValue }
    }
}

struct DefaultReviewService: ReviewService {
    private let session: NetworkSession
    
    init(session: NetworkSession) {
        self.session = session
    }
    
    func fetchComments(of reviewID: Int, page: Int) async throws -> CommentsBody {
        let request = ReviewAPI.getReviewComments(id: reviewID, page: page)
        
        let response = try await session.request(request, as: CommentsBody.self)
        
        return response.data
    }
    
    func fetchReplies(of commentID: Int) async throws -> RepliesBody {
        let request = ReviewAPI.getReviewCommentReplies(id: commentID)
        
        let response = try await session.request(request, as: RepliesBody.self)
        
        return response.data
    }
    
    func createComment(of reviewID: Int, content: String, isSecret: Bool) async throws -> CommentDTO {
        let body = ReviewCommentRequest(comment: content, secret: isSecret)
        let request = ReviewAPI.postReviewComment(id: reviewID, requestBody: body)
        
        let response = try await session.request(request, as: CommentDTO.self)
        
        return response.data
    }
    
    func createReply(of commentID: Int, content: String, isSecret: Bool) async throws -> ReplyDTO {
        let body = ReviewCommentRequest(comment: content, secret: isSecret)
        
        let request = ReviewAPI.postReviewCommentReply(id: commentID, requestBody: body)
        
        let response = try await session.request(request, as: ReplyDTO.self)
        
        return response.data
    }
    
    func createReviewLike(of reviewID: Int) async throws {
        let request = ReviewAPI.reviewLike(id: reviewID)
        
        try await session.execute(request)
        
    }
    
    func deleteReviewLike(of reviewID: Int) async throws {
        let request = ReviewAPI.reviewUnlike(id: reviewID)
        
        try await session.execute(request)}
}

struct MockReviewService: ReviewService {
    func fetchComments(of reviewID: Int, page: Int) async throws -> CommentsBody {
        CommentsBody(
            comments: [
                CommentDTO(
                    id: 4,
                    content: "리뷰3 - 첫 번째 댓글입니다.",
                    commenter: "alice",
                    createdAt: "2025-05-23T17:43:51",
                    replyCount: 0,
                    isSecret: true,
                    isVisible: true
                ),
                CommentDTO(
                    id: 5,
                    content: "리뷰3 - 두 번째 댓글입니다.",
                    commenter: "bob",
                    createdAt: "2025-05-23T17:43:51",
                    replyCount: 2,
                    isSecret: false,
                    isVisible: true
                ),
                CommentDTO(
                    id: 6,
                    content: "리뷰3 - 세 번째 댓글입니다.",
                    commenter: "charlie",
                    createdAt: "2025-05-23T17:43:51",
                    replyCount: 0,
                    isSecret: true,
                    isVisible: true
                )
            ],
            hasNext: false,
            currentPage: 0
        )
    }
    
    func fetchReplies(of commentID: Int) async throws -> RepliesBody {
        RepliesBody(
            replies: [
                ReplyDTO(
                    id: 29,
                    content: "답글입니다 하이요~",
                    replier: "alice",
                    createdAt: "2025-05-29T15:10:28",
                    isSecret: false,
                    isVisible: true
                ),
                ReplyDTO(
                    id: 30,
                    content: "답글입니다 하이요~",
                    replier: "alice",
                    createdAt: "2025-05-29T15:12:22",
                    isSecret: false,
                    isVisible: true
                ),
            ],
            hasNext: false,
            currentPage: 0
        )
    }
    
    func createComment(of reviewID: Int, content: String, isSecret: Bool) async throws -> CommentDTO {
        CommentDTO(
            id: 35,
            content: content,
            commenter: "alice",
            createdAt: "2025-05-29T15:19:25.036526",
            replyCount: 0,
            isSecret: isSecret,
            isVisible: true
        )
    }
    
    func createReply(of commentID: Int, content: String, isSecret: Bool) async throws -> ReplyDTO {
        ReplyDTO(
            id: 36,
            content: content,
            replier: "bob",
            createdAt: "2025-05-29T16:23:30.353742",
            isSecret: isSecret,
            isVisible: true
        )
    }
    
    func createReviewLike(of reviewID: Int) async throws {}
    
    func deleteReviewLike(of reviewID: Int) async throws {}
}
