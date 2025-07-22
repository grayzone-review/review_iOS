//
//  SearchService.swift
//  Up
//
//  Created by Jun Young Lee on 6/13/25.
//

import Dependencies

protocol SearchService {
    func fetchSearchedCompanies(theme: SearchTheme, keyword: String, latitude: Double, longitude: Double, page: Int) async throws -> SearchedCompaniesBody
    func fetchProposedCompanies(keyword: String, latitude: Double, longitude: Double) async throws -> ProposedCompaniesBody
}

private enum SearchServiceKey: DependencyKey {
    static let liveValue: any SearchService = DefaultSearchService(session: AlamofireNetworkSession())
    static let previewValue: any SearchService = DefaultSearchService(session: AlamofireNetworkSession())
    static var testValue: any SearchService = MockSearchService()
}

extension DependencyValues {
    var searchService: any SearchService {
        get { self[SearchServiceKey.self] }
        set { self[SearchServiceKey.self] = newValue }
    }
}

struct DefaultSearchService: SearchService {
    private let session: NetworkSession
    
    init(session: NetworkSession) {
        self.session = session
    }
    
    func fetchSearchedCompanies(theme: SearchTheme, keyword: String, latitude: Double, longitude: Double, page: Int) async throws -> SearchedCompaniesBody {
        let request: SearchAPI
        switch theme {
        case .keyword:
            request = .searchedCompanies(keyword: keyword, latitude: latitude, longitude: longitude, page: page)
        case .near:
            request = .nearByCompanies(latitude: latitude, longitude: longitude, page: page)
        case .neighborhood:
            request = .mainRegionCompanies(latitude: latitude, longitude: longitude, page: page)
        case .interest:
            request = .interestedRegionCompanies(latitude: latitude, longitude: longitude, page: page)
        }
        let response = try await session.request(request, as: SearchedCompaniesBody.self)
        
        switch response {
        case .success(let response):
            return response.data
        case .failure(let error):
            throw error
        }
    }
    
    func fetchProposedCompanies(keyword: String, latitude: Double, longitude: Double) async throws -> ProposedCompaniesBody {
        let request = SearchAPI.proposedCompanies(keyword: keyword, latitude: latitude, longitude: longitude)
        let response = try await session.request(request, as: ProposedCompaniesBody.self)
        
        switch response {
        case .success(let response):
            return response.data
        case .failure(let error):
            throw error
        }
    }
}

struct MockSearchService: SearchService {
    func fetchSearchedCompanies(theme: SearchTheme, keyword: String, latitude: Double, longitude: Double, page: Int) async throws -> SearchedCompaniesBody {
        SearchedCompaniesBody(
            companies: [
                SearchedCompanyDTO(
                    id: 7540,
                    name: "바스버거 광화문점",
                    address: "서울특별시 중구 무교동 11 광일빌딩 지하1층 ",
                    totalRating: 3.3,
                    isFollowed: true,
                    distance: 0.23416418140220643,
                    reviewTitle: "리뷰 제목"
                ),
                SearchedCompanyDTO(
                    id: 12681,
                    name: "브루클린더버거조인트 청계천점",
                    address: "서울특별시 중구 무교동 77 ",
                    totalRating: 0.0,
                    isFollowed: false,
                    distance: 0.2649729031981153,
                    reviewTitle: nil
                ),
                SearchedCompanyDTO(
                    id: 3650,
                    name: "침스버거",
                    address: "서울특별시 종로구 종로1가 24 르메이에르종로타운1 ",
                    totalRating: 0.0,
                    isFollowed: false,
                    distance: 0.4694415423917943,
                    reviewTitle: nil
                ),
                SearchedCompanyDTO(
                    id: 4018,
                    name: "브루클린 더 버거 조인트 광화문 디타워점",
                    address: "서울특별시 종로구 청진동 246 D타워 123,124,125호 ",
                    totalRating: 0.0,
                    isFollowed: false,
                    distance: 0.5146869003560908,
                    reviewTitle: nil
                ),
                SearchedCompanyDTO(
                    id: 8085,
                    name: "경성함바그&버거스캔들 명동점",
                    address: "서울특별시 중구 을지로2가 199-52 2층 ",
                    totalRating: 0.0,
                    isFollowed: false,
                    distance: 0.5577430254969458,
                    reviewTitle: nil
                ),
                SearchedCompanyDTO(
                    id: 8887,
                    name: "바스버거 서소문시청역점",
                    address: "서울특별시 중구 서소문동 120-28 ",
                    totalRating: 0.0,
                    isFollowed: false,
                    distance: 0.5953119049246598,
                    reviewTitle: nil
                ),
                SearchedCompanyDTO(
                    id: 4019,
                    name: "주식회사 티시스 엘꾸비또, 버거링맨",
                    address: "서울특별시 종로구 신문로1가 226 흥국생명빌딩 지하2층 ",
                    totalRating: 0.0,
                    isFollowed: false,
                    distance: 0.6183172035135013,
                    reviewTitle: nil
                ),
                SearchedCompanyDTO(
                    id: 2721,
                    name: "버거킹 종로구청점",
                    address: "서울특별시 종로구 수송동 68-1 호수빌딩 101호,201호 ",
                    totalRating: 0.0,
                    isFollowed: false,
                    distance: 0.7100229153818288,
                    reviewTitle: nil
                ),
                SearchedCompanyDTO(
                    id: 7295,
                    name: "피크버거&스테이크",
                    address: "서울특별시 중구 저동1가 114 대신파이낸스센터(Daishin Finance Center) ",
                    totalRating: 0.0,
                    isFollowed: false,
                    distance: 0.8098895610288,
                    reviewTitle: nil
                ),
                SearchedCompanyDTO(
                    id: 12101,
                    name: "버거운 녀석들",
                    address: "서울특별시 중구 남대문로5가 21-1 ",
                    totalRating: 0.0,
                    isFollowed: false,
                    distance: 0.880889544495731,
                    reviewTitle: nil
                ),
            ],
            hasNext: true,
            currentPage: 0,
            totalCount: 2513
        )
    }
    
    func fetchProposedCompanies(keyword: String, latitude: Double, longitude: Double) async throws -> ProposedCompaniesBody {
        ProposedCompaniesBody(
            companies: [
                ProposedCompanyDTO(
                    id: 7540,
                    name: "바스버거 광화문점",
                    address: "서울특별시 중구 무교동 11 광일빌딩 지하1층 ",
                    totalRating: 3.3
                ),
                ProposedCompanyDTO(
                    id: 12681,
                    name: "브루클린더버거조인트 청계천점",
                    address: "서울특별시 중구 무교동 77 ",
                    totalRating: 0.0
                ),
                ProposedCompanyDTO(
                    id: 3650,
                    name: "침스버거",
                    address: "서울특별시 종로구 종로1가 24 르메이에르종로타운1 ",
                    totalRating: 0.0
                ),
                ProposedCompanyDTO(
                    id: 4018,
                    name: "브루클린 더 버거 조인트 광화문 디타워점",
                    address: "서울특별시 종로구 청진동 246 D타워 123,124,125호 ",
                    totalRating: 0.0
                ),
                ProposedCompanyDTO(
                    id: 8085,
                    name: "경성함바그&버거스캔들 명동점",
                    address: "서울특별시 중구 을지로2가 199-52 2층 ",
                    totalRating: 0.0
                ),
                ProposedCompanyDTO(
                    id: 8887,
                    name: "바스버거 서소문시청역점",
                    address: "서울특별시 중구 서소문동 120-28 ",
                    totalRating: 0.0
                ),
                ProposedCompanyDTO(
                    id: 4019,
                    name: "주식회사 티시스 엘꾸비또, 버거링맨",
                    address: "서울특별시 종로구 신문로1가 226 흥국생명빌딩 지하2층 ",
                    totalRating: 0.0
                ),
                ProposedCompanyDTO(
                    id: 2721,
                    name: "버거킹 종로구청점",
                    address: "서울특별시 종로구 수송동 68-1 호수빌딩 101호,201호 ",
                    totalRating: 0.0
                ),
                ProposedCompanyDTO(
                    id: 7295,
                    name: "피크버거&스테이크",
                    address: "서울특별시 중구 저동1가 114 대신파이낸스센터(Daishin Finance Center) ",
                    totalRating: 0.0
                ),
                ProposedCompanyDTO(
                    id: 12101,
                    name: "버거운 녀석들",
                    address: "서울특별시 중구 남대문로5가 21-1 ",
                    totalRating: 0.0
                ),
            ],
            hasNext: true,
            currentPage: 0
        )
    }
}
