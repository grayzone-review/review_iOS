//
//  KaKaoSignInManager.swift
//  Up
//
//  Created by Wonbi on 7/19/25.
//

import KakaoSDKUser
import Foundation

@MainActor
final class KaKaoSignInManager {
    static let shared = KaKaoSignInManager()

    func signIn() async throws -> String {
        if UserApi.isKakaoTalkLoginAvailable() {
            let token: String = try await withCheckedThrowingContinuation { continuation in
                UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                    if let error = error {
                        print(error)
                        continuation.resume(throwing: error)
                        return
                    }
                    if let oauthToken {
                        print("카카오톡 로그인 success \(String(describing: oauthToken.accessToken))")
                        continuation.resume(returning: oauthToken.accessToken)
                    } else {
                        continuation.resume(throwing: NSError(domain: "KaKao Talk Sign In Error with Unknown Reason", code: -1))
                    }
                }
                
            }
            
            return token
        } else {
            let token: String = try await withCheckedThrowingContinuation { continuation in
                UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                    if let error = error {
                        print(error)
                        continuation.resume(throwing: error)
                        return
                    }
                    if let oauthToken {
                        print("카카오 계정 로그인 success \(String(describing: oauthToken.accessToken))")
                        continuation.resume(returning: oauthToken.accessToken)
                    } else {
                        continuation.resume(throwing: NSError(domain: "KaKao Account Sign In Error with Unknown Reason", code: -1))
                    }
                }
            }
            
            return token
        }
    }
}
