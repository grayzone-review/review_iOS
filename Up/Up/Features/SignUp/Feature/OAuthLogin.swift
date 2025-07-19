//
//  OAuthLogin.swift
//  Up
//
//  Created by Wonbi on 7/2/25.
//

import SwiftUI
import AuthenticationServices

import ComposableArchitecture
import KakaoSDKUser

@Reducer
struct OAuthLoginFeature {
    
    @ObservableState
    struct State: Equatable {
        
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case appleButtonTapped
        case kakaoButtonTapped
        case login(OAuthResult)
        case handleError(Error)
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case tokenReceived
        }
    }
    
    @Dependency(\.signUpService) var signUpService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(_):
                return .none
            case .appleButtonTapped:
                return .run { send in
                    let result = try await AppleSignInManager.shared.signIn()
                    print("ID Token:", result.idToken)
                    print("User ID:", result.userID)
                    print("Email:", result.email ?? "nil")
                    
                    let data = OAuthResult(token: result.idToken, provider: "apple")
                    
                    await send(.login(data))
                }
            case .kakaoButtonTapped:
                return .run { send in
                    let result = try await KaKaoSignInManager.shared.signIn()
                    
                    let data = OAuthResult(token: result, provider: "kakao")
                    
                    await send(.login(data))
                }
            case let .login(data):
                return .run { send in
//                    let response = try await signUpService.login(oauthToken: data.token, oauthProvider: OAuthProvider(rawValue: data.provider))
//                    
//                    await SecureTokenManager.shared.setAccessToken(response.accessToken)
//                    await SecureTokenManager.shared.setRefreshToken(response.refreshToken)
                    
                    await send(.delegate(.tokenReceived))
                } catch: { error, send in
                    await send(.handleError(error))
                }
                
            case let .handleError(error):
                print(error)
                return .none
            case .delegate(_):
                return .none
            }
        }
    }
}

struct OAuthLoginView: View {
    @Bindable var store: StoreOf<OAuthLoginFeature>
    
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer()
            
            AppImage.logo.image
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
            
            Text("현직자들이 말하는\n소규모 사업장 리뷰")
                .pretendard(.h1Bold, color: .white)
            
            Spacer()
            
            VStack(spacing: 12) {
                kakaoSignUpButton
                
                appleSignUpButton
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(AppColor.orange40.color)
    }
    
    var appleSignUpButton: some View {
        Button {
            store.send(.appleButtonTapped)
        } label: {
            HStack(spacing: 8) {
                Spacer()
                
                AppIcon.appleFill.image(width: 24, height: 24, appColor: .white)
                
                Text("Apple계정으로 시작하기")
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
    
    var kakaoSignUpButton: some View {
        Button {
            store.send(.kakaoButtonTapped)
        } label: {
            HStack(spacing: 10) {
                Spacer()
                
                AppIcon.kakaoFill.image(width: 24, height: 24)
                
                Text("카카오톡으로 시작하기")
                    .pretendard(.body1Bold, sysyemColor: .hex("#3D1D1C"))
                
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
    OAuthLoginView(
        store: Store(
            initialState: OAuthLoginFeature.State()
        ) {
            OAuthLoginFeature()
        }
    )
}
