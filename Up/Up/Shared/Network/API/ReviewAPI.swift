//
//  ReviewAPI.swift
//  Up
//
//  Created by Wonbi on 6/6/25.
//

import Foundation

import Alamofire

/// CompanyAPI 엔드포인트 정의
enum ReviewAPI: Sendable, URLRequestConvertible {
    case getReviewComments(id: String)
    case getReviewCommentReplies(id: String)
    case postReviewComment(id: String, requestBody: ReviewCommentRequest)
    case postReviewCommentReply(id: String, requestBody: ReviewCommentRequest)
    case reviewLike(id: String)
    case reviewUnlike(id: String)

    // 기본 서버 URL
    private var baseURL: URL {
        return URL(string: AppConfig.Network.host)!
    }

    // 각 케이스별 HTTP method
    private var method: HTTPMethod {
        switch self {
        case .getReviewComments:
            return .get
        case .getReviewCommentReplies:
            return .get
        case .postReviewComment:
            return .post
        case .postReviewCommentReply:
            return .post
        case .reviewLike:
            return .post
        case .reviewUnlike:
            return .delete
        }
    }

    // 각 케이스별 경로(Path)
    private var path: String {
        switch self {
        case let .getReviewComments(id), let .postReviewComment(id, _):
            return "/api/reviews/\(id)/comments"
        case let .getReviewCommentReplies(id), let .postReviewCommentReply(id, _):
            return "/api/comments/\(id)/replies"
        case let .reviewLike(id), let .reviewUnlike(id):
            return "/api/reviews/\(id)/likes"
        }
    }
    
    // `URLRequestConvertible` 프로토콜 요구사항 구현
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = try URLRequest(url: url, method: method)
        
        switch self {
        case let .postReviewComment(_, body), let .postReviewCommentReply(_, body):
            let params = body.toDictionary()
            request.httpBody = try JSONSerialization.data(withJSONObject: params)
        default:
            break
        }
        
        return request
    }
}
