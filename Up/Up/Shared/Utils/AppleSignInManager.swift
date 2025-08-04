//
//  AppleSignInManager.swift
//  Up
//
//  Created by Wonbi on 7/2/25.
//

import AuthenticationServices

// MARK: — Swift Concurrency 래퍼
@MainActor
final class AppleSignInManager: NSObject {
    static let shared = AppleSignInManager()

    // CheckedContinuation을 저장할 프로퍼티
    private var continuation: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?

    /// Apple로 로그인: ID 토큰, 사용자ID, (최초 로그인 시) 이메일을 리턴
    func signIn() async throws -> (idToken: String, credential: ASAuthorizationAppleIDCredential) {
        let credential = try await withCheckedThrowingContinuation { cont in
            self.continuation = cont
            
            // 1) 요청 생성
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.email, .fullName]
            
            // 2) 컨트롤러 구성
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
        
        // 3) credential에서 값 꺼내기
        guard let tokenData = credential.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8)
        else {
            throw NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "ID 토큰을 변환할 수 없습니다."])
        }
        return (idToken: idToken, credential: credential)
    }
}

// MARK: — ASAuthorizationControllerDelegate
extension AppleSignInManager: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let cred = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: NSError(domain: "AppleSignIn", code: -2, userInfo: nil))
            return
        }
        continuation?.resume(returning: cred)
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        continuation?.resume(throwing: error)
    }
}

// MARK: — ASPresentationContextProvider
extension AppleSignInManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {
        // 키 윈도우를 반환
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first { $0.isKeyWindow } }
            .first ?? ASPresentationAnchor()
    }
}
