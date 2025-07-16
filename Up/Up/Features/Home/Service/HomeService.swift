//
//  HomeService.swift
//  Up
//
//  Created by Jun Young Lee on 7/17/25.
//

import Dependencies

protocol HomeService {
    func fetchUser() async throws -> UserDTO
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
}
