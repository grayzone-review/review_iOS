//
//  SignUp.swift
//  Up
//
//  Created by Wonbi on 6/30/25.
//

import SwiftUI

import ComposableArchitecture

@Reducer
struct SignUpFeature {
    @Reducer
    enum Path {
        case searchArea(SearchAreaFeature)
        case termDetail(TermDetailFeature)
    }
    
    @ObservableState
    struct State: Equatable {
        let oAuthData: OAuthResult
        
        var path = StackState<Path.State>()
        
        /// 사용자에게 입력받은 nickname
        var nickname: String = ""
        /// 사용자가 닉네임 중복체크를 했는지 확인하기 위한 상태값
        var dupCheckFieldState: DupCheckTextField.FieldState = .default
        /// 사용자가 설정한 우리동네
        var myArea: District?
        /// 사용자가 설정한 관심동네 리스트
        var preferredAreaList: [District] = []
        /// 사용자가 관심동네를 3개 설정했는지 나타내는 값
        var isPreferredFull: Bool = false
        /// 약관 리스트
        var termList: [TermsData] = []
        var allRequiredTermsAgreed: Bool = false
        /// 중복 검사 결과를 보여주는 값
        var notice: String = "2~12자 이내로 입력가능하며, 한글, 영문, 숫자 사용이 가능합니다."
        /// 사용자가 가입 가능한 상태인지 나타내는 값
        var canSignUp: Bool {
            self.dupCheckFieldState == .valid &&
            self.myArea != nil &&
            self.termList.filter { $0.isRequired }.allSatisfy { $0.isAgree }
        }
        /// 비동기 로직이 수행중인지 아닌지 나타내는 값
        var isLoading: Bool = false
        
        /// 에러 핸들링
        var shouldShowErrorPopup: Bool = false
        var errorMessage: String = ""
        
        var isLoadingIndicatorShowing = false
        var isSuccessAlertShowing = false
        
        var message: String {
            "회원가입이 완료되었습니다."
        }
    }
    
    enum Action: BindableAction {
        case path(StackActionOf<Path>)
        case binding(BindingAction<State>)
        case viewAppear
        case addTermsList([TermsData])
        case xButtonTapped
        case checkNicknameTapped
        case updateNotice(isSuccess: Bool, message: String)
        case deletePreferredAreaTapped(District)
        case agreeAllTermsTapped
        case agreeTermTapped(code: String)
        case signUpTapped
        case turnIsLoadingIndicatorShowing(Bool)
        case showSuccessAlert
        case alertDoneButtonTapped
        case delegate(Delegate)
        case handleError(Error)
        
        enum Delegate: Equatable {
            case signUpSucceded
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.signUpService) var signUpService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce {
            state,
            action in
            switch action {
            case .binding:
                return .none
            case let .path(.element(id: _, action: .searchArea(.delegate(.selectedArea(context, area))))):
                switch context {
                case .myArea:
                    state.myArea = area
                case .preferedArea:
                    guard !state.isPreferredFull,
                          !state.preferredAreaList.contains(area) else { return .none }
                    
                    state.preferredAreaList.append(area)
                    state.isPreferredFull = state.preferredAreaList.count >= 3
                }
                return .none
            case .path:
                return .none
            case .viewAppear:
                guard state.termList.isEmpty,
                      !state.isLoading else { return .none }
                state.isLoading = true
                
                return .run { send in
                    let data = try await signUpService.fetchTermsList()
                    
                    await send(.addTermsList(data))
                } catch: { error, send in
                    await send(.handleError(error))
                }
            case let .addTermsList(termsData):
                termsData.forEach { data in
                    state.termList.append(data)
                }
                state.isLoading = false
                
                return .none
            case .xButtonTapped:
                return .run { _ in
                    await dismiss()
                }
            case .checkNicknameTapped:
                let text = state.nickname
                
                return .run { send in
                    let result = try await signUpService.verifyNickname(text)
                    
                    await send(.updateNotice(isSuccess: result.isSuccess, message: result.message))
                } catch: { error, send in
                    await send(.handleError(error))
                }
            case let .updateNotice(isSuccess, message):
                state.dupCheckFieldState = isSuccess ? .valid : .invalid
                state.notice = message
                
                return .none
            case let .deletePreferredAreaTapped(district):
                state.preferredAreaList.removeAll { $0 == district }
                state.isPreferredFull = state.preferredAreaList.count >= 3
                
                return .none
                
            case .agreeAllTermsTapped:
                state.allRequiredTermsAgreed.toggle()
                
                (0..<state.termList.count).forEach { index in
                    state.termList[index].isAgree = state.allRequiredTermsAgreed
                }
                
                return .none
            case let .agreeTermTapped(code):
                guard let index = state.termList.firstIndex(where: { $0.code == code }) else { return .none }
                
                state.termList[index].isAgree.toggle()
                
                state.allRequiredTermsAgreed = state.termList.allSatisfy { $0.isAgree }
                
                return .none
            case .signUpTapped:
                guard let mainRegionId = state.myArea?.id else { return .none }
                let oauthData = state.oAuthData
                let interestedRegionIds = state.preferredAreaList.map { $0.id }
                let nickname = state.nickname
                let agreements = state.termList.compactMap { $0.isAgree ? $0.code : nil }
                
                return .run { send in
                    await send(.turnIsLoadingIndicatorShowing(true))
                    try await signUpService.signUp(
                        oauthData: oauthData,
                        mainRegionId: mainRegionId,
                        interestedRegionIds: interestedRegionIds,
                        nickname: nickname,
                        agreements: agreements
                    )
                    
                    let token = try await signUpService.login(
                        oauthToken: oauthData.token,
                        authorizationCode: oauthData.authorizationCode,
                        oauthProvider: .init(rawValue: oauthData.provider)
                    )
                    
                    await SecureTokenManager.shared.setAccessToken(token.accessToken)
                    await SecureTokenManager.shared.setRefreshToken(token.refreshToken)
                    await send(.turnIsLoadingIndicatorShowing(false))
                    await send(.showSuccessAlert)
                } catch: { error, send in
                    await send(.turnIsLoadingIndicatorShowing(false))
                    return await send(.handleError(error))
                }
                
            case let .turnIsLoadingIndicatorShowing(isShowing):
                state.isLoadingIndicatorShowing = isShowing
                return .none
                
            case .showSuccessAlert:
                state.isSuccessAlertShowing = true
                return .none
                
            case .alertDoneButtonTapped:
                return .run { send in
                    await send(.delegate(.signUpSucceded))
                    await dismiss()
                }
                
            case .delegate:
                return .none
                
            case let .handleError(error):
                if let fail = error as? FailResponse {
                    state.shouldShowErrorPopup = true
                    state.errorMessage = fail.message
                } else {
                    state.shouldShowErrorPopup = true
                    state.errorMessage = "알수없는 문제가 발생했습니다.\n문제가 반복된다면 고객센터에 문의해주세요."
                }
                return .none
            }
        }
        .forEach(\.path, action: \.path) { Path.body }
    }
}

extension SignUpFeature.Path.State: Equatable {}

struct SignUpView: View {
    @FocusState var isFocused: Bool
//    @State var isFocused: Bool = false
    
    @Bindable var store: StoreOf<SignUpFeature>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ScrollView {
                mainView
                
                Spacer()
                    .frame(height: 92)
            }
            .background(Color.white
                .onTapGesture {
                    isFocused = false
                })
            .overlay(alignment: .bottom) {
                AppButton(
                    style: .fill,
                    size: .large,
                    text: "가입하기",
                    isEnabled: store.canSignUp
                ) {
                    store.send(.signUpTapped)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
                .background {
                    AppColor.white.color.ignoresSafeArea()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    IconButton(
                        icon: .closeLine) {
                            store.send(.xButtonTapped)
                        }
                }
                ToolbarItem(placement: .principal) {
                    Text("회원 가입")
                        .pretendard(.h2, color: .gray90)
                }
            }
            .loadingIndicator(store.isLoadingIndicatorShowing)
            .appAlert(
                $store.isSuccessAlertShowing,
                isSuccess: true,
                message: store.message
            ) {
                store.send(.alertDoneButtonTapped)
            }
            .appAlert($store.shouldShowErrorPopup, isSuccess: false, message: store.errorMessage)
            .onChange(of: store.dupCheckFieldState) { old, new in
                if old != new, new == .valid {
                    isFocused = false
                }
            }
        } destination: { store in
            switch store.case {
            case let .searchArea(store):
                SearchAreaView(store: store)
            case let .termDetail(store):
                TermDetailView(store: store)
            }
        }
        .onAppear {
            store.send(.viewAppear)
        }
    }
    
    var mainView: some View {
        VStack(spacing: 0) {
            inputNicknameView
            
            setMyAreaView
            
            setPreferredAreaView
            
            termsAgreeView
        }
    }
    
    var inputNicknameView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("닉네임")
                .pretendard(.h3Bold, color: .gray90)
            
            DupCheckTextField(
                text: $store.nickname,
                state: $store.dupCheckFieldState,
                isFocused: $isFocused,
                noti: $store.notice,
                placeholder: "닉네임"
            ) {
                store.send(.checkNicknameTapped)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
    }
    
    var setMyAreaView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("우리 동네 설정")
                .pretendard(.h3Bold, color: .gray90)
            
            NavigationLink(state: SignUpFeature.Path.State.searchArea(SearchAreaFeature.State(context: .myArea))) {
                Text(store.myArea?.buttonName ?? "동 검색하기")
                    .pretendard(.body1Regular, color: store.myArea == nil ? .gray50 : .gray90)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(AppColor.gray20.color, lineWidth: 1)
                    }
                    .contentShape(Rectangle())
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
    }
    
    var setPreferredAreaView: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("관심 동네 설정 (선택)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .pretendard(.h3Bold, color: .gray90)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    Spacer(minLength: 10)
                    
                    ForEach(Array(store.preferredAreaList)) { district in
                        makePreferredAreaButton(district)
                    }
                    if !store.isPreferredFull {
                        NavigationLink(
                            state: SignUpFeature.Path.State.searchArea(SearchAreaFeature.State(context: .preferedArea, selectedList: store.preferredAreaList))
                        ) {
                            AppButton(
                                style: .fill,
                                size: .regular,
                                mode: .intrinsic,
                                text: "추가하기",
                                isLabel: true
                            )
                            .padding(.top, 8)
                        }
                    }
                    Spacer(minLength: 10)
                }
            }
            .scrollIndicators(.never)
        }
        .padding(.vertical, 20)
    }
    
    func makePreferredAreaButton(_ district: District) -> some View {
        AppButton(
            style: .strokeFill,
            size: .regular,
            mode: .intrinsic,
            text: district.buttonName,
            isEnabled: false
        )
        .overlay(alignment: .topTrailing) {
            AppIcon.closeCircleLineRed24.image(width: 24, height: 24)
                .offset(x: 6, y: -5)
                .onTapGesture {
                    store.send(.deletePreferredAreaTapped(district))
                }
        }
        .padding(.top, 8)
    }
    
    var termsAgreeView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                CheckBox(isSelected: store.allRequiredTermsAgreed)
                
                Text("약관 전체 동의")
                    .pretendard(.body1SemiBold, color: .gray70)
                    .lineLimit(1)
                
                Spacer(minLength: 0)
            }
            .padding(.vertical, 16)
            .contentShape(Rectangle())
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(AppColor.gray20.color)
                    .frame(height: 1)
            }
            .onTapGesture {
                store.send(.agreeAllTermsTapped)
            }
            
            ForEach(store.termList) { term in
                makeTermAgreeCell(term: term)
            }
        }
        .padding(.horizontal, 20)
    }
    
    func makeTermAgreeCell(term: TermsData) -> some View {
        HStack(spacing: 0) {
            HStack(spacing: 8) {
                CheckBox(isSelected: term.isAgree)
                
                Text(term.title)
                    .pretendard(.body1Regular, color: .gray70)
                    .lineLimit(1)
                
                Spacer(minLength: 0)
            }
            .padding(.vertical, 16)
            .contentShape(Rectangle())
            .onTapGesture {
                store.send(.agreeTermTapped(code: term.code))
            }
            
            NavigationLink(state: SignUpFeature.Path.State.termDetail(.init(term: term))) {
                HStack(spacing: 4) {
                    Text("자세히")
                        .pretendard(.captionRegular, color: .gray50)
                    
                    AppIcon.arrowRight.image(
                        width: 14,
                        height: 14,
                        appColor: .gray50
                    )
                }
                .padding(.vertical, 16)
                .contentShape(Rectangle())
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView(
            store: Store(
                initialState: SignUpFeature.State(oAuthData: OAuthResult(token: "", provider: "")),
                reducer: {
                    SignUpFeature()
                }
            )
        )
    }
}
