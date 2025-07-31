//
//  LaunchScreenService.swift
//  Up
//
//  Created by Jun Young Lee on 7/26/25.
//

import Foundation
import Dependencies

protocol LaunchScreenService {
    func tokenReissue() async throws -> TokenData
}

private enum LaunchScreenServiceKey: DependencyKey {
    static let liveValue: any LaunchScreenService = DefaultLaunchScreenService(session: AlamofireNetworkSession())
    static let previewValue: any LaunchScreenService = DefaultLaunchScreenService(session: AlamofireNetworkSession())
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
    private let tokenManager = SecureTokenManager.shared
    
    init(session: NetworkSession) {
        self.session = session
    }
    
    func tokenReissue() async throws -> TokenData {
        guard let refreshToken = await tokenManager.getRefreshToken() else {
            throw NSError(domain: "There is no RefreshToken", code: -1)
        }
        
        let body = RefreshTokenRequest(refreshToken: refreshToken)
        let request = LaunchScreenAPI.tokenReissue(requestBody: body)
        let response = try await session.request(request, as: LoginResponse.self)
        
        switch response {
        case .success(let success):
            return TokenData(from: success.data)
        case .failure(let failure):
            throw failure
        }
    }
}

struct MockLaunchScreenService: LaunchScreenService {
    func tokenReissue() async throws -> TokenData {
        TokenData(accessToken: "accessToken", refreshToken: "refreshToken")
    }
}
