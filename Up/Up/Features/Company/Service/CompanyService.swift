//
//  CompanyService.swift
//  Up
//
//  Created by Jun Young Lee on 5/31/25.
//

import Dependencies

protocol CompanyService {
    func fetchCompany(of id: Int) async throws -> CompanyDTO
    func fetchReviews(of companyID: Int, page: Int) async throws -> ReviewsBody
    func createCompanyFollowing(of companyID: Int) async throws
    func deleteCompanyFollowing(of companyID: Int) async throws
}

private enum CompanyServiceKey: DependencyKey {
    static let liveValue: any CompanyService = DefaultCompanyService(session: AlamofireNetworkSession(interceptor: AuthIDInterceptor()))
    static let previewValue: any CompanyService = DefaultCompanyService(session: AlamofireNetworkSession(interceptor: AuthIDInterceptor()))
    static var testValue: any CompanyService = MockCompanyService()
}

extension DependencyValues {
    var companyService: any CompanyService {
        get { self[CompanyServiceKey.self] }
        set { self[CompanyServiceKey.self] = newValue }
    }
}

struct DefaultCompanyService: CompanyService {
    private let session: NetworkSession
    
    init(session: NetworkSession) {
        self.session = session
    }
    
    func fetchCompany(of id: Int) async throws -> CompanyDTO {
        let request = CompanyAPI.companyDetail(id: id)
        
        let response = try await session.request(request, as: CompanyDTO.self)
        
        return response.data
    }
    
    func fetchReviews(of companyID: Int, page: Int) async throws -> ReviewsBody {
        let request = CompanyAPI.companyReview(id: companyID, page: page)
        
        let response = try await session.request(request, as: ReviewsBody.self)
        
        return response.data
    }
    
    func createCompanyFollowing(of companyID: Int) async throws {
        let request = CompanyAPI.companyFollow(id: companyID)
        
        try await session.execute(request)
    }
    
    func deleteCompanyFollowing(of companyID: Int) async throws {
        let request = CompanyAPI.companyUnfollow(id: companyID)
        
        try await session.execute(request)
    }
}

struct MockCompanyService: CompanyService {
    func fetchCompany(of id: Int) async throws -> CompanyDTO {
        CompanyDTO(
            id: 3,
            name: "육전국밥 신설동역점",
            permittedAt: "2024-12-10T00:00:00",
            lotNumberAddress: "서울특별시 종로구 숭인동 1256 동보빌딩 ",
            roadNameAddress: "서울특별시 종로구 종로 413, 동보빌딩 지상1층 (숭인동)",
            totalRating: 3.3,
            isFollowed: false,
            longitude: 127.02241002457775,
            latitude: 37.575715910020854
        )
    }
    
    func fetchReviews(of companyID: Int, page: Int) async throws -> ReviewsBody {
        ReviewsBody(
            reviews: [
                ReviewDTO(
                    id: 2,
                    rating: RatingDTO(
                        workLifeBalance: 2.5,
                        welfare: 3.0,
                        salary: 4.0,
                        companyCulture: 2.5,
                        management: 2.0
                    ),
                    reviewer: "alice",
                    title: "좋은 회사입니다.",
                    advantagePoint: "복지가 좋아요.",
                    disadvantagePoint: "야근이 많아요.",
                    managementFeedback: "소통이 필요합니다.",
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
                    reviewer: "bob",
                    title: "별로였어요.",
                    advantagePoint: "연봉이 높아요.",
                    disadvantagePoint: "상사가 별로예요.",
                    managementFeedback: "리더십이 부족해요.",
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
                    reviewer: "charlie",
                    title: "그럭저럭 괜찮아요.",
                    advantagePoint: "동료들",
                    disadvantagePoint: "동료들...",
                    managementFeedback: "교육 기회가 부족해요.",
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
    
    func createCompanyFollowing(of companyID: Int) async throws {}
    
    func deleteCompanyFollowing(of companyID: Int) async throws {}
}
