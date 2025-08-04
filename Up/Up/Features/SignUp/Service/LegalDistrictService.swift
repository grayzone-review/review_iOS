//
//  LegalDistrictService.swift
//  Up
//
//  Created by Wonbi on 7/14/25.
//

import Dependencies

protocol LegalDistrictService {
    func searchArea(keyword: String, page: Int) async throws -> LegalDistrictsData
}

private enum LegalDistrictServiceKey: DependencyKey {
    static let liveValue: any LegalDistrictService = DefaultLegalDistrictService(session: AlamofireNetworkSession())
    static let previewValue: any LegalDistrictService = DefaultLegalDistrictService(session: AlamofireNetworkSession())
    static var testValue: any LegalDistrictService = MockLegalDistrictService()
}

extension DependencyValues {
    var legalDistrictService: any LegalDistrictService {
        get { self[LegalDistrictServiceKey.self] }
        set { self[LegalDistrictServiceKey.self] = newValue }
    }
}

struct DefaultLegalDistrictService: LegalDistrictService {
    private let session: NetworkSession
    
    init(session: NetworkSession) {
        self.session = session
    }
    
    func searchArea(keyword: String, page: Int) async throws -> LegalDistrictsData {
        let request = try LegalDistrictsAPI.legalDistricts(keyword: keyword, page: page).asURLRequest()
        
        let response = try await session.request(request, as: LegalDistrictResponse.self)
        
        switch response {
        case .success(let success):
            return success.data.toDomain()
        case .failure(let failure):
            throw failure
        }
    }
}

struct MockLegalDistrictService: LegalDistrictService {
    func searchArea(keyword: String, page: Int) async throws -> LegalDistrictsData {
        return LegalDistrictsData(
            hasNext: false,
            currentPage: 1,
            legalDistricts: [
                District(
                    id: 0,
                    name: "서울시 강북구 수유동"
                )
            ]
        )
    }
}


