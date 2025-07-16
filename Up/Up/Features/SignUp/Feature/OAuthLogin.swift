//
//  OAuthLogin.swift
//  Up
//
//  Created by Wonbi on 7/2/25.
//

import SwiftUI
import ComposableArchitecture
import AuthenticationServices

import KakaoSDKUser

struct OAuthLoginView: View {
    var body: some View {
        VStack(spacing: 12) {
            
            Spacer()
            
            Text("로고가 들어갈 예정")
            
            Spacer()
            
            kakaoSignUpButton
            
            appleSignUpButton
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.white)
    }
    
    var appleSignUpButton: some View {
        Button {
            Task {
                do {
                    let result = try await AppleSignInManager.shared.signIn()
                    print("ID Token:", result.idToken)
                    print("User ID:", result.userID)
                    print("Email:", result.email ?? "nil")
                } catch {
                    print("error: \(error)")
                }
            }
        } label: {
            HStack(spacing: 8) {
                Spacer()
                
                AppIcon.appleFill.image(width: 24, height: 24, appColor: .white)
                
                Text("Apple로 계속하기")
                    .pretendard(.body1Bold, color: .white)
                
                Spacer()
            }
            .padding(.vertical, 14)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColor.gray90.color)
            }
        }
    }
    
    private func configure(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.email, .fullName]
    }
    
    private func handle(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                // 👇 Identity Token (JWT) 추출
                if let tokenData = credential.identityToken,
                   let idToken = String(data: tokenData, encoding: .utf8) {
                    // idToken: 서버에 전송할 JWT
                    print("ID Token: \(idToken)")
                }
                
                // 👇 (최초 로그인 시) 이메일/이름
                let email = credential.email         // 최초 한 번만 non-nil
                let fullName = credential.fullName   // PersonNameComponents?
                
                // 👇 Apple 고유 사용자 ID (sub)
                let userID = credential.user
                
            }
            
        case .failure(let error):
            break
        }
    }
    
    var kakaoSignUpButton: some View {
        Button {
            UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                if let error = error {
                    print(error)
                } else {
                    print("카카오톡 로그인 success \(oauthToken?.accessToken)")
                }
            }
        } label: {
            HStack(spacing: 10) {
                Spacer()
                
                AppIcon.kakaoFill.image(width: 24, height: 24, appColor: .black)
                
                Text("카카오톡으로 시작하기")
                    .pretendard(.body1Bold, sysyemColor: .black.opacity(0.85))
                
                Spacer()
            }
            .padding(.vertical, 14)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.hex("#FEE500"))
            }
        }
    }
}

#Preview {
    OAuthLoginView()
}
