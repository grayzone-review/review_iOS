//
//  UpApp.swift
//  UpApp
//
//  Created by Jun Young Lee on 5/24/25.
//

import SwiftUI
import ComposableArchitecture
import KakaoMapsSDK
import KakaoSDKCommon
import KakaoSDKAuth

@Reducer
struct UpFeature {
    @ObservableState
    struct State: Equatable {
        var onboarding = OnboardingFeature.State()
        var oauthLogin = OAuthLoginFeature.State()
        var loginPath = StackState<LoginPath.State>()
        var mainPath = StackState<MainPath.State>()
        var main = MainFeature.State()
        var isFirstLaunch = true
        var isBootstrapping = true
        var needLogin = true
    }
    
    enum Action {
        case appLaunched
        case initKakaoSDK
        case setIsFirstLaunch
        case tokenReissue
        case setNeedLogin(Bool)
        case reset
        case endBootstrap
        case oauthLogin(OAuthLoginFeature.Action)
        case onboarding(OnboardingFeature.Action)
        case loginPath(StackActionOf<LoginPath>)
        case mainPath(StackActionOf<MainPath>)
        case main(MainFeature.Action)
    }
    
    @Reducer
    enum LoginPath {
        case signUp(SignUpFeature)
        case searchArea(SearchAreaFeature)
    }
    
    @Reducer
    enum MainPath {
        case activity(MyActivityFeature)
        case homeReview(HomeReviewFeature)
        case search(SearchCompanyFeature)
        case detail(CompanyDetailFeature)
        case report(ReportFeature)
        case editMyInfo(EditMyInfoFeature)
        case searchArea(SearchAreaFeature)
    }
    
    @Dependency(\.launchScreenService) var launchScreenService
    @Dependency(\.userDefaultsService) var userDefaultsService
    
    var body: some ReducerOf<Self> {
        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }
        
        Scope(state: \.main, action: \.main) {
            MainFeature()
        }

        Scope(state: \.oauthLogin, action: \.oauthLogin) {
            OAuthLoginFeature()
        }

        Reduce { state, action in
            switch action {
            case .appLaunched:
                return .run { send in
                    await send(.initKakaoSDK)
                    await send(.setIsFirstLaunch)
                }
                
            case .initKakaoSDK:
                guard
                    let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as? String,
                    let kakaoRestApiKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_REST_API_KEY") as? String
                else {
                  fatalError("Info.plist에서 Key 정보를 읽어오지 못했습니다.")
                }
                
                SDKInitializer.InitSDK(appKey: kakaoAppKey)
                KakaoSDK.initSDK(appKey: kakaoAppKey)
                AppConfig.kakaoRestApiKey = kakaoRestApiKey
                return .none
                
            case .setIsFirstLaunch:
                let hasLaunchedBefore = try? userDefaultsService.fetch(key: "hasLaunchedBefore", type: Bool.self)
                state.isFirstLaunch = hasLaunchedBefore != true
                
                // 앱 설치 후 첫 실행이면 키체인을 초기화합니다.
                if hasLaunchedBefore != true {
                    return .run { send in
                        await send(.reset)
                        await send(.endBootstrap)
                    }
                } else {
                    return .send(.tokenReissue)
                }
                
            case .tokenReissue:
                return .run { send in
                    let token = try await launchScreenService.tokenReissue()
                    await SecureTokenManager.shared.setAccessToken(token.accessToken)
                    await SecureTokenManager.shared.setRefreshToken(token.refreshToken)
                    await send(.setNeedLogin(false))
                    await send(.endBootstrap)
                } catch: { error, send in
                    await send(.reset)
                    await send(.endBootstrap)
                }
                
            case let .setNeedLogin(needLogin):
                state.needLogin = needLogin
                return .none
                
            case .reset:
                state.needLogin = true
                state.main = MainFeature.State()
                
                return .run { send in
                    await SecureTokenManager.shared.clearTokens()
                    userDefaultsService.reset()
                }
                
            case .endBootstrap:
                state.isBootstrapping = false
                return .none
                
            case .onboarding(.delegate(.startButtonTapped)):
                try? userDefaultsService.save(key: "hasLaunchedBefore", value: true)
                state.isFirstLaunch = false
                
                return .none
            case .onboarding:
                return .none
                
            case .oauthLogin(.delegate(.loginFinished)):
                return .send(.setNeedLogin(false))
                
            case .oauthLogin:
                return .none
                
            case .loginPath:
                return .none
                
            case let .mainPath(.element(id: _, action: .searchArea(.delegate(.selectedArea(context, area))))):
                /// delegate를 수신한 시점에는 뷰가 아직 dismiss되지 않았습니다. (선택 후 0.3초 후에 화면을 dismiss해야 하기 때문)
                /// 따라서, 내 정보 수정 화면은 mainPath 스택의 맨 뒤에서 2번째에 위치해 있습니다. [.., .., EditMyInfo, SearchArea] 와 같은 느낌.
                /// 결과적으로 EditMyInfo의 인덱스는 mainPath.ids.count - 2 가 됩니다.
                let editInfoID = state.mainPath.ids.count - 2
                guard editInfoID >= 0 else { return .none }
                
                let editID = state.mainPath.ids[editInfoID]
                
                return .send(
                  .mainPath(.element(
                    id: editID,
                    action: .editMyInfo(.selectedArea(context, area))
                  ))
                )
            case .mainPath:
                return .none
                
            case .main:
                return .none
            }
        }
        .forEach(\.loginPath, action: \.loginPath)
        .forEach(\.mainPath, action: \.mainPath)
    }
}

extension UpFeature.LoginPath.State: Equatable {}

extension UpFeature.MainPath.State: Equatable {}

struct UpView: View {
    @Bindable var store: StoreOf<UpFeature>
    
    init(store: StoreOf<UpFeature>) {
        self.store = store
        store.send(.appLaunched)
    }
    
    var body: some View {
        if store.isBootstrapping {
            launchScreen
        } else if store.isFirstLaunch {
            onboarding
        } else if store.needLogin {
            login
        } else {
            main
        }
    }
    
    private var launchScreen: some View {
        SplashView()
    }
    
    private var onboarding: some View {
        OnboardingView(
            store: store.scope(state: \.onboarding, action: \.onboarding)
        )
    }
    
    private var login: some View {
        NavigationStack(path: $store.scope(state: \.loginPath, action: \.loginPath)) {
            OAuthLoginView(store: store.scope(state: \.oauthLogin, action: \.oauthLogin))
        } destination: { store in
            switch store.case {
            case let .signUp(store):
                SignUpView(store: store)
            case let .searchArea(store):
                SearchAreaView(store: store)
            }
        }
    }
    
    private var main: some View {
        NavigationStack(path: $store.scope(state: \.mainPath, action: \.mainPath)) {
            MainView(store: store.scope(state: \.main, action: \.main))
        } destination: { store in
            switch store.case {
            case let .activity(activityStore):
                MyActivityView(store: activityStore)
                
            case let .homeReview(homeReviewStore):
                HomeReviewView(store: homeReviewStore)
                
            case let .search(searchStore):
                SearchCompanyView(store: searchStore)
                
            case let .detail(detailStore):
                CompanyDetailView(store: detailStore)
                
            case let .report(reportStore):
                ReportView(store: reportStore)
            case let .editMyInfo(store):
                EditMyInfoView(store: store)
            case let .searchArea(store):
                SearchAreaView(store: store)
            }
        }
    }
}

@main
struct UpApp: App {
    @MainActor
    static let store = Store(initialState: UpFeature.State()) {
        UpFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            UpView(store: Self.store)
                .onOpenURL { url in
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}

#Preview {
    UpView(
        store: Store(
            initialState: UpFeature.State()
        ) {
            UpFeature()
        }
    )
}

extension UINavigationController: @retroactive ObservableObject, @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
