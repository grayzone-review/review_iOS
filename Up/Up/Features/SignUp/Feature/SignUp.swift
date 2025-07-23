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
        var path = StackState<Path.State>()
        
        /// 사용자에게 입력받은 nickname
        var nickname: String = ""
        var dupCheckFieldState: DupCheckTextField.FieldState = .default
        // TODO: - API나오면 요청하는 값에 맞게 모델(엔티티)을 구현해야함
        /// 사용자가 설정한 우리동네
        var myArea: District?
        /// 사용자가 설정한 관심동네 리스트
        var preferredAreaList: [District] = [.init(id: 0, name: "수유동")]
        /// 사용자가 관심동네를 3개 설정했는지 나타내는 값
        var isPreferredFull: Bool = false
        // TODO: - API나오면 약관 리스트에 대한 모델을 구현해야함 (ex: title(제목), url(보여줄 웹 뷰의 URL), isRequired(필수 동의 약관인지에 대한 여부), isAgree(변수; 사용자가 동의했는지에 대한 여부))
        /// 약관 리스트
        var termList: [TermsData] = []
        var requiredTermCodes: [String] = []
        /// 중복 검사 결과를 보여주는 값
        var notice: String = "2~12자 이내로 입력가능하며, 한글, 영문, 숫자 사용이 가능합니다."
        var isAvailableName: Bool = false
        /// 사용자가 가입 가능한 상태인지 나타내는 값
        var canSignUp: Bool {
            self.dupCheckFieldState == .valid &&
            self.myArea != nil
        }
        /// 비동기 로직이 수행중인지 아닌지 나타내는 값
        var isLoading: Bool = false
    }
    
    enum Action: BindableAction {
        case path(StackActionOf<Path>)
        case binding(BindingAction<State>)
        case viewInit
        case addTermsList([TermsData])
        case xButtonTapped
        case checkNicknameTapped
        case updateNotice(isSuccess: Bool, message: String)
        case deletePreferredAreaTapped(Int)
        case agreeAllTermsTapped
        case agreeTermTapped(code: String)
        case termDetailTapped(url: String)
        case handleCanSignUp
        case signUpTapped
        case handleError(Error)
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.signUpService) var signUpService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case let .path(.element(id: state.path.ids.first!, action: .searchArea(.delegate(.selectedArea(context, area))))):
                switch context {
                case .myArea:
                    state.myArea = area
                case .preferedArea:
                    guard !state.isPreferredFull else { return .none }
                    
                    state.preferredAreaList.append(area)
                    state.isPreferredFull = state.preferredAreaList.count >= 3
                }
                return .none
            case .path:
                return .none
            case .viewInit:
                guard state.termList.isEmpty, !state.isLoading else { return .none }
                state.isLoading = true
                
                return .run { send in
                    let data = try await signUpService.fetchTermsList()
                    
                    await send(.addTermsList(data))
                } catch: { error, send in
                    await send(.handleError(error))
                }
            case let .addTermsList(termsData):
                termsData.forEach { data in
                    if data.isRequired {
                        state.requiredTermCodes.append(data.code)
                    }
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
            case let .deletePreferredAreaTapped(index):
                // TODO: - 관심 동네 제거
                print("deletePreferredAreaTapped \(index)")
                return .none
            case .agreeAllTermsTapped:
                // TODO: - 약관 모두 동의 선택
                print("agreeAllTermsTapped")
                return .none
            case let .agreeTermTapped(code):
                // TODO: - 약관 동의 체크
                print("agreeTermTapped \(index)")
                return .none
            case let .termDetailTapped(index):
                // TODO: - 약관 상세 화면으로 이동
                print("termDetailTapped \(index)")
                return .none
            case .handleCanSignUp:
                // TODO: - 가입 가능한 상태인지 체크
                return .none
            case .signUpTapped:
                // TODO: - 회원 가입
                print("signUpTapped")
                return .none
            case let .handleError(error):
                // TODO: - 에러 핸들링
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
    
    init(store: StoreOf<SignUpFeature>) {
        self.store = store
        store.send(.viewInit)
    }
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ScrollView {
                mainView
                
                Spacer()
                    .frame(height: 92)
            }
            .background(Color.white)
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
                        .onTapGesture {
                            print("mainView onTapGesture \(isFocused)")
                            isFocused = false
                        }
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
                .pretendard(.h3, color: .gray90)
            
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
                .pretendard(.h3, color: .gray90)
            
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
                .pretendard(.h3, color: .gray90)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    Spacer(minLength: 10)
                    
                    ForEach(Array(store.preferredAreaList.enumerated()), id: \.element.id) { index, area in
                        makePreferredAreaButton(title: area.buttonName, index: index)
                    }
                    
                    NavigationLink(state: SignUpFeature.Path.State.searchArea(SearchAreaFeature.State(context: .preferedArea))) {
                        AppButton(
                            style: .fill,
                            size: .regular,
                            mode: .intrinsic,
                            text: "추가하기"
                        )
                        .padding(.top, 8)
                    }
                    Spacer(minLength: 10)
                }
            }
            .scrollIndicators(.never)
        }
        .padding(.vertical, 20)
    }
    
    func makePreferredAreaButton(title: String, index: Int) -> some View {
        AppButton(
            style: .strokeFill,
            size: .regular,
            mode: .intrinsic,
            text: title,
            isEnabled: false
        )
        .overlay(alignment: .topTrailing) {
            IconButton(icon: .closeCircleLineRed24) {
                store.send(.deletePreferredAreaTapped(index))
            }
            .offset(x: 7, y: -7)
        }
        .padding(.top, 8)
    }
    
    var termsAgreeView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                CheckBox(isSelected: .random())
                
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
                initialState: SignUpFeature.State(),
                reducer: {
                    SignUpFeature()
                }
            )
        )
    }
}
