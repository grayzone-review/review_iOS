//
//  EditMyInfoFeature.swift
//  Up
//
//  Created by Wonbi on 7/26/25.
//

import SwiftUI

import ComposableArchitecture

@Reducer
struct EditMyInfoFeature {
    @Reducer
    enum Path {
        case searchArea(SearchAreaFeature)
    }
    
    @ObservableState
    struct State: Equatable {
//        @Shared(.user) var user
        
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
        /// 중복 검사 결과를 보여주는 값
        var notice: String = "2~12자 이내로 입력가능하며, 한글, 영문, 숫자 사용이 가능합니다."
        /// 사용자의 정보가 수정 가능한 상태인지 나타내는 값
        var canEdit: Bool {
            self.dupCheckFieldState == .valid &&
            self.myArea != nil
        }
        /// 비동기 로직이 수행중인지 아닌지 나타내는 값
        var isLoading: Bool = false
        
        /// 에러 핸들링
        var shouldShowErrorPopup: Bool = false
        var errorMessage: String = ""
    }
    
    enum Action: BindableAction {
        case path(StackActionOf<Path>)
        case binding(BindingAction<State>)
        case viewAppear
        case xButtonTapped
        case checkNicknameTapped
        case updateNotice(isSuccess: Bool, message: String)
        case deletePreferredAreaTapped(District)
        case editTapped
        case handleError(Error)
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.myPageService) var myPageService
    @Dependency(\.signUpService) var signUpService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
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
                
                return .none
                
            case .editTapped:
                guard let mainRegionId = state.myArea?.id else { return .none }
                let interestedRegionIds = state.preferredAreaList.map { $0.id }
                let nickname = state.nickname
                
                return .run { send in
                    try await myPageService.editUser(
                        name: nickname,
                        mainRegionID: mainRegionId,
                        interestedRegionIDs: interestedRegionIds
                    )
                } catch: { error, send in
                    return await send(.handleError(error))
                }
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

extension EditMyInfoFeature.Path.State: Equatable {}

struct EditMyInfoView: View {
    @FocusState var isFocused: Bool
    
    @Bindable var store: StoreOf<EditMyInfoFeature>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            VStack {
                mainView
                
                Spacer()
                
                AppButton(
                    style: .fill,
                    size: .large,
                    text: "수정하기",
                    isEnabled: store.canEdit
                ) {
                    store.send(.editTapped)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
            }
            .background {
                Color.white.onTapGesture {
                    isFocused = false
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    IconButton(icon: .arrowLeft) {
                        store.send(.xButtonTapped)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("내 정보 수정")
                        .pretendard(.h2, color: .gray90)
                }
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
                Text(store.myArea?.name ?? "동 검색하기")
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
                            state: SignUpFeature.Path.State.searchArea(SearchAreaFeature.State(context: .preferedArea))
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
