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
    @Reducer
    enum Destination {
        case signUp(SignUpFeature)
    }
    
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        var shouldShowErrorAlert: Bool = false
        var errorMessage: String = ""
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case appleButtonTapped
        case kakaoButtonTapped
        case goToSignUp(OAuthResult)
        case login(OAuthResult)
        case handleError(Error)
        case destination(PresentationAction<Destination.Action>)
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case loginFinished
        }
    }
    
    @Dependency(\.signUpService) var signUpService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce {
            state,
            action in
            switch action {
            case .binding(_):
                return .none
            case .appleButtonTapped:
                return .run { send in
                    let result = try await AppleSignInManager.shared.signIn()
                    
                    guard let tokenData = result.credential.identityToken,
                          let codeData = result.credential.authorizationCode,
                          let idToken = String(data: tokenData, encoding: .utf8),
                          let authorizationCode = String(data: codeData, encoding: .utf8)
                    else {
                        throw NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "ID 토큰을 변환할 수 없습니다."])
                    }
                    
                    print("idToken:\n\(idToken)\n")
                    print("authorizationCode:\n\(authorizationCode)")
                    
                    let data = OAuthResult(
                        token: idToken,
                        authorizationCode: authorizationCode,
                        provider: "apple"
                    )
                    
                    await send(.login(data))
                } catch: { error, send in
                    await send(.handleError(error))
                }
            case .kakaoButtonTapped:
                return .run { send in
                    let result = try await KaKaoSignInManager.shared.signIn()
                    
                    let data = OAuthResult(token: result, provider: "kakao")
                    
                    await send(.login(data))
                } catch: { error, send in
                    await send(.handleError(error))
                }
            case let .goToSignUp(data):
                state.destination = .signUp(SignUpFeature.State(oAuthData: data))
                
                return .none
            case let .login(data):
                return .run { send in
                    let response = try await signUpService.login(oauthToken: data.token, oauthProvider: OAuthProvider(rawValue: data.provider))
                    
                    await SecureTokenManager.shared.setAccessToken(response.accessToken)
                    await SecureTokenManager.shared.setRefreshToken(response.refreshToken)
                    await send(.delegate(.loginFinished))
                } catch: { error, send in
                    if let error = error as? FailResponse, error.code == 3001 {
                        await send(.goToSignUp(data))
                    } else {
                        await send(.handleError(error))
                    }
                }
                
            case let .handleError(error):
                if let fail = error as? FailResponse {
                    state.errorMessage = fail.message
                } else {
                    state.errorMessage = "알수없는 문제가 발생했습니다.\n문제가 반복된다면 고객센터에 문의해주세요."
                }
                state.shouldShowErrorAlert = true
                
                return .none
            case .destination(.presented(.signUp(.delegate(.signUpSucceded)))):
                return .send(.delegate(.loginFinished))
                
            case .destination:
                return .none
                
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension OAuthLoginFeature.Destination.State: Equatable {}

struct OAuthLoginView: View {
    @Bindable var store: StoreOf<OAuthLoginFeature>
    
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer()
            
            AppImage.logo.image
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .padding(.bottom, 16)
            
            Text("현직자들이 말하는\n소규모 사업장 리뷰")
                .multilineTextAlignment(.center)
                .pretendard(.h1Bold, color: .white)
            
            Spacer()
            
            VStack(spacing: 12) {
                kakaoSignUpButton
                
                appleSignUpButton
            }
            .fullScreenCover(
                item: $store.scope(state: \.destination?.signUp, action: \.destination.signUp)
            ) { store in
                SignUpView(store: store)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(AppColor.orange40.color)
        .appAlert($store.shouldShowErrorAlert, isSuccess: false, message: store.errorMessage)
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
