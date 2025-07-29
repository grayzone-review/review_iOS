//
//  MyPageService.swift
//  Up
//
//  Created by Jun Young Lee on 7/24/25.
//

import Foundation
import Dependencies

protocol MyPageService {
    func editUser(name: String, mainRegionID: Int, interestedRegionIDs: [Int]) async throws
    func report(reporter: String, target: String, type: String, description: String) async throws
    func resign() async throws
    func signOut() async throws
}

private enum MyPageServiceKey: DependencyKey {
    static let liveValue: any MyPageService = DefaultMyPageService(session: AlamofireNetworkSession())
    static let previewValue: any MyPageService = DefaultMyPageService(session: AlamofireNetworkSession())
    static var testValue: any MyPageService = MockMyPageServiceService()
}

extension DependencyValues {
    var myPageService: any MyPageService {
        get { self[MyPageServiceKey.self] }
        set { self[MyPageServiceKey.self] = newValue }
    }
}

struct DefaultMyPageService: MyPageService {
    private let session: NetworkSession
    private let tokenManager = TokenManager.shared
    
    init(session: NetworkSession) {
        self.session = session
    }
    
    func editUser(name: String, mainRegionID: Int, interestedRegionIDs: [Int]) async throws {
        let body = EditUserRequest(mainRegionId: mainRegionID, interestedRegionIds: interestedRegionIDs, nickname: name)
        let request = MyPageAPI.editUser(requestBody: body)
        
        try await session.execute(request)
    }
    
    func report(reporter: String, target: String, type: String, description: String) async throws {
        let body = ReportRequest(reporterName: reporter, targetName: target, reportType: type, description: description)
        let request = MyPageAPI.report(requestBody: body)
        
        try await session.execute(request)
    }
    
    func resign() async throws {
        guard let refreshToken = await tokenManager.getRefreshToken() else {
            throw NSError(domain: "There is no RefreshToken", code: -1)
        }
        
        let body = RefreshTokenRequest(refreshToken: refreshToken)
        let request = MyPageAPI.resign(requestBody: body)
        
        try await session.execute(request)
    }
    
    func signOut() async throws {
        guard let refreshToken = await tokenManager.getRefreshToken() else {
            throw NSError(domain: "There is no RefreshToken", code: -1)
        }
        
        let body = RefreshTokenRequest(refreshToken: refreshToken)
        let request = MyPageAPI.signOut(requestBody: body)
        
        try await session.execute(request)
    }
}

struct MockMyPageServiceService: MyPageService {
    func editUser(name: String, mainRegionID: Int, interestedRegionIDs: [Int]) async throws {}
    
    func report(reporter: String, target: String, type: String, description: String) async throws {}
    
    func resign() async throws {}
    
    func signOut() async throws {}
}
