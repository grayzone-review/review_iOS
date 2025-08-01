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
    case getReviewComments(id: Int, page: Int, size: Int = 10)
    case getReviewCommentReplies(id: Int, page: Int, size: Int = 10)
    case postReviewComment(id: Int, requestBody: ReviewCommentRequest)
    case postReviewCommentReply(id: Int, requestBody: ReviewCommentRequest)
    case reviewLike(id: Int)
    case reviewUnlike(id: Int)

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
        case let .getReviewComments(id, _, _), let .postReviewComment(id, _):
            return "/api/reviews/\(id)/comments"
        case let .getReviewCommentReplies(id, _, _), let .postReviewCommentReply(id, _):
            return "/api/comments/\(id)/replies"
        case let .reviewLike(id), let .reviewUnlike(id):
            return "/api/reviews/\(id)/likes"
        }
    }
    
    // `URLRequestConvertible` 프로토콜 요구사항 구현
    func asURLRequest() throws -> URLRequest {
        var components = URLComponents(string: AppConfig.Network.host + path)!
        
        switch self {
        case let .getReviewComments(_, page, size), let .getReviewCommentReplies(_, page, size):
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "size", value: "\(size)"),
                URLQueryItem(name: "sort", value: "createdAt,desc")
            ]
            guard let url = components.url else { throw NSError(domain: "Invalid URL", code: -1) }
            let request = try URLRequest(url: url, method: method)
            
            return request
        case let .postReviewComment(_, body), let .postReviewCommentReply(_, body):
            guard let url = components.url else { throw NSError(domain: "Invalid URL", code: -1) }
            var request = try URLRequest(url: url, method: method)
            let params = body.toDictionary()
            request.httpBody = try JSONSerialization.data(withJSONObject: params)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            return request
        default:
            guard let url = components.url else { throw NSError(domain: "Invalid URL", code: -1) }
            let request = try URLRequest(url: url, method: method)
            
            return request
        }
    }
}
