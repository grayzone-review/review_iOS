//
//  LaunchScreenService.swift
//  Up
//
//  Created by Jun Young Lee on 7/26/25.
//

import Foundation
import Dependencies

protocol LaunchScreenService {
    func tokenReissue() async throws
}

private enum LaunchScreenServiceKey: DependencyKey {
    static let liveValue: any LaunchScreenService = DefaultLaunchScreenService(session: AlamofireNetworkSession(interceptor: AuthIDInterceptor()))
    static let previewValue: any LaunchScreenService = DefaultLaunchScreenService(session: AlamofireNetworkSession(interceptor: AuthIDInterceptor()))
    static var testValue: any LaunchScreenService = MockLaunchScreenService()
}

extension DependencyValues {
    var launchScreenService: any LaunchScreenService {
        get { self[LaunchScreenServiceKey.self] }
        set { self[LaunchScreenServiceKey.self] = newValue }
    }
}

struct DefaultLaunchScreenService: LaunchScreenService {
    private let session: NetworkSession
    private let tokenManager = TokenManager.shared
    
    init(session: NetworkSession) {
        self.session = session
    }
    
    func tokenReissue() async throws {
        guard let refreshToken = await tokenManager.getRefreshToken() else {
            throw NSError(domain: "There is no RefreshToken", code: -1)
        }
        
        let body = RefreshTokenRequest(refreshToken: refreshToken)
        let request = MyPageAPI.signOut(requestBody: body)
        let error = try await session.execute(request)
        
        if let error {
            throw error
        }
    }
}

struct MockLaunchScreenService: LaunchScreenService {
    func tokenReissue() async throws {}
}
