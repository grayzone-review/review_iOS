//
//  CompanyService.swift
//  Grayzone
//
//  Created by Jun Young Lee on 5/31/25.
//

import Foundation

protocol CompanyService {
    func fetchCompany(of id: Int) async -> NetworkResponse<CompanyDTO>
    func fetchReviews(of companyID: Int) async -> NetworkResponse<ReviewsBody>
    func fetchComments(of reviewID: Int) async -> NetworkResponse<CommentsBody>
    func fetchReplies(of commentID: Int) async -> NetworkResponse<CommentsBody>
    func createComment(of reviewID: Int, content: String, isSecret: Bool) async -> NetworkResponse<CommentDTO>
    func createReply(of commentID: Int, content: String, isSecret: Bool) async -> NetworkResponse<ReplyDTO>
}
