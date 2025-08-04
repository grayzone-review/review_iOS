//
//  SignUpService.swift
//  Up
//
//  Created by Wonbi on 7/9/25.
//

import Dependencies

protocol SignUpService {
    func fetchTermsList() async throws -> [TermsData]
    func verifyNickname(_ nickname: String) async throws -> VerifyResult
    func signUp(
        oauthData: OAuthResult,
        mainRegionId: Int,
        interestedRegionIds: [Int],
        nickname: String,
        agreements: [String]
    ) async throws
    func login(oauthToken: String, authorizationCode: String?, oauthProvider: OAuthProvider) async throws -> TokenData
}

private enum SignUpServiceKey: DependencyKey {
    static let liveValue: any SignUpService = DefaultSignUpService(session: AlamofireNetworkSession())
    static let previewValue: any SignUpService = DefaultSignUpService(session: AlamofireNetworkSession())
    static var testValue: any SignUpService = MockSignUpService()
}

extension DependencyValues {
    var signUpService: any SignUpService {
        get { self[SignUpServiceKey.self] }
        set { self[SignUpServiceKey.self] = newValue }
    }
}

struct DefaultSignUpService: SignUpService {
    private let session: NetworkSession
    
    init(session: NetworkSession) {
        self.session = session
    }
    
    func fetchTermsList() async throws -> [TermsData] {
        let request = SignUpAPI.terms
        
        let response = try await session.request(request, as: TermsListResponse.self)
        
        switch response {
        case .success(let success):
            return success.data.toDomain()
        case .failure(let failure):
            throw failure
        }
    }
    
    func verifyNickname(_ nickname: String) async throws -> VerifyResult {
        let requestBody = VerifyNicknameRequest(nickname: nickname)
        let request = SignUpAPI.verifyNickname(requestBody)
        do {
            let response = try await session.request(request, as: NilResponse.self)
            
            switch response {
            case .success(let success):
                return VerifyResult(isSuccess: true, message: success.message)
            case .failure(let failure):
                return VerifyResult(isSuccess: false, message: failure.message)
            }
        } catch {
            throw error
        }
    }
    
    func signUp(
        oauthData: OAuthResult,
        mainRegionId: Int,
        interestedRegionIds: [Int],
        nickname: String,
        agreements: [String]
    ) async throws {
        let requestBody = SignUpRequest(
            oauthToken: oauthData.token,
            oauthProvider: .init(rawValue: oauthData.provider),
            mainRegionId: mainRegionId,
            interestedRegionIds: interestedRegionIds,
            nickname: nickname,
            agreements: agreements
        )
        let request = SignUpAPI.signUp(requestBody)
        
        let response = try await session.request(request, as: NilResponse.self)
        
        switch response {
        case .success:
            return
        case .failure(let failure):
            throw failure
        }
    }
    
    func login(oauthToken: String, authorizationCode: String?, oauthProvider: OAuthProvider) async throws -> TokenData {
        let requestBody = LoginRequset(
            oauthToken: oauthToken,
            authorizationCode: authorizationCode,
            oauthProvider: oauthProvider
        )
        let request = SignUpAPI.login(requestBody)
        
        let response = try await session.request(request, as: LoginResponse.self)
        
        switch response {
        case .success(let success):
            return TokenData(from: success.data)
        case .failure(let failure):
            throw failure
        }
    }
}

struct MockSignUpService: SignUpService {
    
    func fetchTermsList() async throws -> [TermsData] {
        return [
            TermsData(
                term: "[필수] 서비스 이용 약관",
                url: "",
                code: "serviceUse",
                isRequired: true
            ),
            TermsData(
                term: "[필수] 개인정보 수집 및 이용 동의",
                url: "",
                code: "privacy",
                isRequired: true
            ),
            TermsData(
                term: "[필수] 위치기반 서비스 동의",
                url: "",
                code: "location",
                isRequired: true
            )
        ]
    }
    
    func verifyNickname(_ nickname: String) async throws -> VerifyResult {
        return VerifyResult(isSuccess: true, message: "성공")
    }
    
    func signUp(oauthData: OAuthResult, mainRegionId: Int, interestedRegionIds: [Int], nickname: String, agreements: [String]) async throws {
        
    }
    
    func login(oauthToken: String, authorizationCode: String?, oauthProvider: OAuthProvider) async throws -> TokenData {
        return TokenData(accessToken: "", refreshToken: "")
    }
}
