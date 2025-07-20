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
}

private enum HomeServiceKey: DependencyKey {
    static let liveValue: any HomeService = MockHomeService()
    static let previewValue: any HomeService = MockHomeService()
    static var testValue: any HomeService = MockHomeService()
}

extension DependencyValues {
    var homeService: any HomeService {
        get { self[HomeServiceKey.self] }
        set { self[HomeServiceKey.self] = newValue }
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
}
