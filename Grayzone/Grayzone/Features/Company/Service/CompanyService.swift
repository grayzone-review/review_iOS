//
//  CompanyService.swift
//  Grayzone
//
//  Created by Jun Young Lee on 5/31/25.
//

import Dependencies

protocol CompanyService {
    func fetchCompany(of id: Int) async -> CompanyDTO
    func fetchReviews(of companyID: Int) async -> ReviewsBody
    func fetchComments(of reviewID: Int) async -> CommentsBody
    func fetchReplies(of commentID: Int) async -> RepliesBody
    func createComment(of reviewID: Int, content: String, isSecret: Bool) async -> CommentDTO
    func createReply(of commentID: Int, content: String, isSecret: Bool) async -> ReplyDTO
}

private enum CompanyServiceKey: DependencyKey {
    static let liveValue: any CompanyService = MockCompanyService() // 실제로 사용할 구조체를 작성한 이후 변경 필요
    static let previewValue: any CompanyService = MockCompanyService()
}

extension DependencyValues {
  var companyService: any CompanyService {
    get { self[CompanyServiceKey.self] }
    set { self[CompanyServiceKey.self] = newValue }
  }
}

struct MockCompanyService: CompanyService {
    func fetchCompany(of id: Int) async -> CompanyDTO {
        CompanyDTO(
            id: 1,
            name: "포레스트병원",
            permittedAt: "2025-02-28T00:00:00",
            lotNumberAddress: "서울특별시 종로구 원남동 177-1",
            roadNameAddress: "서울특별시 종로구 율곡로 164, 지하1,2층,1층일부,2~8층 (원남동)",
            totalRating: 3.3,
            isFollowed: false,
            xCoordinate: 199642.716240024,
            yCoordinate: 452606.614384676
        )
    }
    
    func fetchReviews(of companyID: Int) async -> ReviewsBody {
        ReviewsBody(
            reivews: [
                ReviewDTO(
                    id: 2,
                    rating: RatingDTO(
                        workLifeBalance: 2.5,
                        welfare: 3.0,
                        salary: 4.0,
                        companyCulture: 2.5,
                        management: 2.0
                    ),
                    title: "좋은 회사입니다.",
                    advantagePoint: "복지가 좋아요.",
                    disadvantagePoint: "야근이 많아요.",
                    managementFeedback: "소통이 필요합니다.",
                    nickname: "alice",
                    job: "백엔드 개발자",
                    employmentPeriod: "1년 이상",
                    createdAt: "2025-05-23T17:40:33",
                    likeCount: 3,
                    commentCount: 19,
                    isLiked: true
                ),
                ReviewDTO(
                    id: 3,
                    rating: RatingDTO(
                        workLifeBalance: 3.5,
                        welfare: 3.5,
                        salary: 3.0,
                        companyCulture: 4.0,
                        management: 3.0
                    ),
                    title: "별로였어요.",
                    advantagePoint: "연봉이 높아요.",
                    disadvantagePoint: "상사가 별로예요.",
                    managementFeedback: "리더십이 부족해요.",
                    nickname: "bob",
                    job: "프론트엔드 개발자",
                    employmentPeriod: "1년 미만",
                    createdAt: "2025-05-23T17:40:33",
                    likeCount: 3,
                    commentCount: 3,
                    isLiked: true
                ),
                ReviewDTO(
                    id: 4,
                    rating: RatingDTO(
                        workLifeBalance: 4.0,
                        welfare: 4.5,
                        salary: 3.5,
                        companyCulture: 4.0,
                        management: 3.0
                    ),
                    title: "그럭저럭 괜찮아요.",
                    advantagePoint: "동료들",
                    disadvantagePoint: "동료들...",
                    managementFeedback: "교육 기회가 부족해요.",
                    nickname: "charlie",
                    job: "디자이너",
                    employmentPeriod: "2년 이상",
                    createdAt: "2025-05-23T17:40:33",
                    likeCount: 3,
                    commentCount: 6,
                    isLiked: true
                )
            ],
            hasNext: false,
            currentPage: 0
        )
    }
    
    func fetchComments(of reviewID: Int) async -> CommentsBody {
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
                    replyCount: 0,
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
    
    func fetchReplies(of commentID: Int) async -> RepliesBody {
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
    
    func createComment(of reviewID: Int, content: String, isSecret: Bool) async -> CommentDTO {
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
    
    func createReply(of commentID: Int, content: String, isSecret: Bool) async -> ReplyDTO {
        ReplyDTO(
            id: 36,
            content: content,
            replier: "bob",
            createdAt: "2025-05-29T16:23:30.353742",
            isSecret: isSecret,
            isVisible: true
        )
    }
}
