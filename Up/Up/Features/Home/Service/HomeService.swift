//
//  HomeService.swift
//  Up
//
//  Created by Jun Young Lee on 7/17/25.
//

import Dependencies

protocol HomeService {
    func fetchUser() async throws -> UserDTO
    func fetchPopularReviews(latitude: Double, longitude: Double, page: Int) async throws -> HomeReviewsBody
    func fetchMainRegionReviews(latitude: Double, longitude: Double, page: Int) async throws -> HomeReviewsBody
    func fetchInterestedRegionReviews(latitude: Double, longitude: Double, page: Int) async throws -> HomeReviewsBody
    func fetchMyReviews(page: Int) async throws -> ActivityReviewsBody
    func fetchInteractedReviews(page: Int) async throws -> ActivityReviewsBody
    func fetchFollowedCompanies(page: Int) async throws -> FollowedCompaniesBody
    func fetchInteractionCounts() async throws -> InteractionCountsDTO
}

private enum HomeServiceKey: DependencyKey {
    static let liveValue: any HomeService = DefaultHomeService(session: AlamofireNetworkSession(interceptor: AuthIDInterceptor()))
    static let previewValue: any HomeService = DefaultHomeService(session: AlamofireNetworkSession(interceptor: AuthIDInterceptor()))
    static var testValue: any HomeService = MockHomeService()
}

extension DependencyValues {
    var homeService: any HomeService {
        get { self[HomeServiceKey.self] }
        set { self[HomeServiceKey.self] = newValue }
    }
}

struct DefaultHomeService: HomeService {
    private let session: NetworkSession
    
    init(session: NetworkSession) {
        self.session = session
    }
    
    func fetchUser() async throws -> UserDTO {
        let request = HomeAPI.user
        let response = try await session.request(request, as: UserDTO.self)
        
        switch response {
        case .success(let response):
            return response.data
        case .failure(let error):
            throw error
        }
    }
    
    func fetchPopularReviews(latitude: Double, longitude: Double, page: Int) async throws -> HomeReviewsBody {
        let request = HomeAPI.popularReviews(latitude: latitude, longitude: longitude, page: page)
        let response = try await session.request(request, as: HomeReviewsBody.self)
        
        switch response {
        case .success(let response):
            return response.data
        case .failure(let error):
            throw error
        }
    }
    
    func fetchMainRegionReviews(latitude: Double, longitude: Double, page: Int) async throws -> HomeReviewsBody {
        let request = HomeAPI.mainRegionReviews(latitude: latitude, longitude: longitude, page: page)
        let response = try await session.request(request, as: HomeReviewsBody.self)
        
        switch response {
        case .success(let response):
            return response.data
        case .failure(let error):
            throw error
        }
    }
    
    func fetchInterestedRegionReviews(latitude: Double, longitude: Double, page: Int) async throws -> HomeReviewsBody {
        let request = HomeAPI.interestedRegionReviews(latitude: latitude, longitude: longitude, page: page)
        let response = try await session.request(request, as: HomeReviewsBody.self)
        
        switch response {
        case .success(let response):
            return response.data
        case .failure(let error):
            throw error
        }
    }
    
    func fetchMyReviews(page: Int) async throws -> ActivityReviewsBody {
        let request = HomeAPI.myReviews(page: page)
        let response = try await session.request(request, as: ActivityReviewsBody.self)
        
        switch response {
        case .success(let response):
            return response.data
        case .failure(let error):
            throw error
        }
    }
    
    func fetchInteractedReviews(page: Int) async throws -> ActivityReviewsBody {
        let request = HomeAPI.interactedReviews(page: page)
        let response = try await session.request(request, as: ActivityReviewsBody.self)
        
        switch response {
        case .success(let response):
            return response.data
        case .failure(let error):
            throw error
        }
    }
    
    func fetchFollowedCompanies(page: Int) async throws -> FollowedCompaniesBody {
        let request = HomeAPI.followedCompanies(page: page)
        let response = try await session.request(request, as: FollowedCompaniesBody.self)
        
        switch response {
        case .success(let response):
            return response.data
        case .failure(let error):
            throw error
        }
    }
    
    func fetchInteractionCounts() async throws -> InteractionCountsDTO {
        let request = HomeAPI.interactionCounts
        let response = try await session.request(request, as: InteractionCountsDTO.self)
        
        switch response {
        case .success(let response):
            return response.data
        case .failure(let error):
            throw error
        }
    }
}

struct MockHomeService: HomeService {
    func fetchUser() async throws -> UserDTO {
        UserDTO(
            nickname: "테스트2",
            mainRegionId: 1618,
            mainRegionAddress: "서울특별시 마포구 공덕동",
            interestedRegions: [
                RegionDTO(
                    id: 1288,
                    address: "서울특별시 성동구 마장동"
                ),
                RegionDTO(
                    id: 1436,
                    address: "서울특별시 관악구 신림동"
                ),
                RegionDTO(
                    id: 1437,
                    address: "서울특별시 관악구 남현동"
                )
            ]
        )
    }
    
    func fetchPopularReviews(latitude: Double, longitude: Double, page: Int) async throws -> HomeReviewsBody {
        HomeReviewsBody(
            reviews: [
                HomeReviewDTO(
                    company: SearchedCompanyDTO(
                        id: 88599,
                        name: "와우",
                        address: "서울특별시 관악구 신림동 1536-14 승도 ",
                        totalRating: 2.04,
                        isFollowed: false,
                        distance: 11.484579605217508,
                        reviewTitle: "반복적인 테스트 진행\n"
                    ),
                    review: ReviewDTO(
                        id: 13,
                        rating: RatingDTO(
                            workLifeBalance: 2.0,
                            welfare: 3.0,
                            salary: 1.0,
                            companyCulture: 1.0,
                            management: 2.0
                        ),
                        reviewer: "test@test.com",
                        title: "반복적인 테스트 진행\n",
                        advantagePoint: "이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요",
                        disadvantagePoint: "이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요",
                        managementFeedback: "이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요",
                        job: "개발자",
                        employmentPeriod: "1년미만",
                        createdAt: "2025-07-09T15:45:03.782472",
                        likeCount: 0,
                        commentCount: 0,
                        isLiked: false
                    )
                ),
                HomeReviewDTO(
                    company: SearchedCompanyDTO(
                        id: 88599,
                        name: "와우",
                        address: "서울특별시 관악구 신림동 1536-14 승도 ",
                        totalRating: 2.04,
                        isFollowed: false,
                        distance: 11.484579605217508,
                        reviewTitle: "반복적인 테스트 진행\n"
                    ),
                    review: ReviewDTO(
                        id: 13,
                        rating: RatingDTO(
                            workLifeBalance: 2.0,
                            welfare: 3.0,
                            salary: 1.0,
                            companyCulture: 1.0,
                            management: 2.0
                        ),
                        reviewer: "test@test.com",
                        title: "반복적인 테스트 진행\n",
                        advantagePoint: "이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요",
                        disadvantagePoint: "이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요",
                        managementFeedback: "이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요",
                        job: "개발자",
                        employmentPeriod: "1년미만",
                        createdAt: "2025-07-09T15:45:03.782472",
                        likeCount: 0,
                        commentCount: 0,
                        isLiked: false
                    )
                ),
                HomeReviewDTO(
                    company: SearchedCompanyDTO(
                        id: 17949,
                        name: "골목집 식당",
                        address: "서울특별시 성동구 마장동 510-20번지 ",
                        totalRating: 2.04,
                        isFollowed: false,
                        distance: 5.401944239509436,
                        reviewTitle: "반복되는 테스트 문구\n"
                    ),
                    review: ReviewDTO(
                        id: 12,
                        rating: RatingDTO(
                            workLifeBalance: 3.0,
                            welfare: 3.0,
                            salary: 1.0,
                            companyCulture: 2.0,
                            management: 2.0
                        ),
                        reviewer: "test@test.com",
                        title: "반복되는 테스트 문구\n",
                        advantagePoint: "이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요",
                        disadvantagePoint: "이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요",
                        managementFeedback: "이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요",
                        job: "개발자",
                        employmentPeriod: "1년미만",
                        createdAt: "2025-07-09T15:42:25.849885",
                        likeCount: 0,
                        commentCount: 0,
                        isLiked: false
                    )
                )            ],
            hasNext: false,
            currentPage: 0
        )
    }
    
    func fetchMainRegionReviews(latitude: Double, longitude: Double, page: Int) async throws -> HomeReviewsBody {
        HomeReviewsBody(
            reviews: [
                HomeReviewDTO(
                    company: SearchedCompanyDTO(
                        id: 54664,
                        name: "마포유가궁중족발",
                        address: "서울특별시 마포구 공덕동 256-10 공덕시장 ",
                        totalRating: 2.04,
                        isFollowed: false,
                        distance: 3.244408117031724,
                        reviewTitle: "반복적인 테스트 진행\n"
                    ),
                    review: ReviewDTO(
                        id: 14,
                        rating: RatingDTO(
                            workLifeBalance: 3.0,
                            welfare: 3.0,
                            salary: 1.0,
                            companyCulture: 1.0,
                            management: 2.0
                        ),
                        reviewer: "test@test.com",
                        title: "반복적인 테스트 진행\n",
                        advantagePoint: "이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요",
                        disadvantagePoint: "이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요",
                        managementFeedback: "이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요",
                        job: "개발자",
                        employmentPeriod: "1년미만",
                        createdAt: "2025-07-09T17:22:47.866104",
                        likeCount: 0,
                        commentCount: 0,
                        isLiked: false
                    )
                )
            ],
            hasNext: false,
            currentPage: 0
        )
    }
    
    func fetchInterestedRegionReviews(latitude: Double, longitude: Double, page: Int) async throws -> HomeReviewsBody {
        HomeReviewsBody(
            reviews: [
                HomeReviewDTO(
                    company: SearchedCompanyDTO(
                        id: 88599,
                        name: "와우",
                        address: "서울특별시 관악구 신림동 1536-14 승도 ",
                        totalRating: 2.04,
                        isFollowed: false,
                        distance: 11.484579605217508,
                        reviewTitle: "반복적인 테스트 진행\n"
                    ),
                    review: ReviewDTO(
                        id: 13,
                        rating: RatingDTO(
                            workLifeBalance: 2.0,
                            welfare: 3.0,
                            salary: 1.0,
                            companyCulture: 1.0,
                            management: 2.0
                        ),
                        reviewer: "test@test.com",
                        title: "반복적인 테스트 진행\n",
                        advantagePoint: "이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요",
                        disadvantagePoint: "이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요",
                        managementFeedback: "이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요이건 테스트에요",
                        job: "개발자",
                        employmentPeriod: "1년미만",
                        createdAt: "2025-07-09T15:45:03.782472",
                        likeCount: 0,
                        commentCount: 0,
                        isLiked: false
                    )
                )
            ],
            hasNext: false,
            currentPage: 0
        )
    }
    
    func fetchMyReviews(page: Int) async throws -> ActivityReviewsBody {
        ActivityReviewsBody(
            reviews: [
                ActivityReviewDTO(
                    id: 1564,
                    totalRating: 3.5,
                    title: "예약이 많아 포트폴리오 쌓기엔 좋지만, 예약 사이 간격이 촘촘해 쉬는 시간이 부족해요",
                    companyID: 4444,
                    companyName: "네일샵 석촌점",
                    companyAddress: "",
                    job: "네일아티스트",
                    createdAt: "2025-05-15T22:35:53.276281",
                    likeCount: 8,
                    commentCount: 13
                ),
                ActivityReviewDTO(
                    id: 1563,
                    totalRating: 4.0,
                    title: "점심시간에 손님이 몰려도 동료들과 호흡이 잘 맞고 사장님이 잘 챙겨줘서 일하기 편해요",
                    companyID: 4445,
                    companyName: "분식집 석촌 김밥왕",
                    companyAddress: "",
                    job: "서빙",
                    createdAt: "2025-03-15T22:35:53.276281",
                    likeCount: 5,
                    commentCount: 2
                )
            ],
            hasNext: false,
            currentPage: 0
        )
    }
    
    func fetchInteractedReviews(page: Int) async throws -> ActivityReviewsBody {
        ActivityReviewsBody(
            reviews: [
                ActivityReviewDTO(
                    id: 1564,
                    totalRating: 3.5,
                    title: "예약이 많아 포트폴리오 쌓기엔 좋지만, 예약 사이 간격이 촘촘해 쉬는 시간이 부족해요",
                    companyID: 4444,
                    companyName: "네일샵 석촌점",
                    companyAddress: "",
                    job: "네일아티스트",
                    createdAt: "2025-05-15T22:35:53.276281",
                    likeCount: 8,
                    commentCount: 13
                ),
                ActivityReviewDTO(
                    id: 1563,
                    totalRating: 4.0,
                    title: "점심시간에 손님이 몰려도 동료들과 호흡이 잘 맞고 사장님이 잘 챙겨줘서 일하기 편해요",
                    companyID: 4445,
                    companyName: "분식집 석촌 김밥왕",
                    companyAddress: "",
                    job: "서빙",
                    createdAt: "2025-03-15T22:35:53.276281",
                    likeCount: 5,
                    commentCount: 2
                )
            ],
            hasNext: false,
            currentPage: 0
        )
    }
    
    func fetchFollowedCompanies(page: Int) async throws -> FollowedCompaniesBody {
        FollowedCompaniesBody(
            companies: [
                FollowedCompanyDTO(
                    id: 209,
                    name: "정일正一 한우",
                    address: "서울특별시 종로구 당주동 100 세종빌딩, 세종아파트 ",
                    totalRating: 2.04,
                    reviewTitle: "반복적인 테스트 진행\n"
                )
            ],
            hasNext: false,
            currentPage: 0
        )
    }
    
    func fetchInteractionCounts() async throws -> InteractionCountsDTO {
        InteractionCountsDTO(
            myReviewCount: 2,
            interactedReviewCount: 2,
            followedCompanyCount: 3
        )
    }
}
