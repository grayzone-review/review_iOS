//
//  FollowedCompanyTabFeature.swift
//  Up
//
//  Created by Jun Young Lee on 7/21/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct FollowedCompanyTabFeature {
    @ObservableState
    struct State: Equatable {
        var companies = [FollowedCompany]()
        var needInitialLoad = true
        var isLoading = false
        var hasNext = true
        var currentPage = 0
        var isAlertShowing = false
        var error: FailResponse?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case viewInit
        case loadNext
        case setIsLoading(Bool)
        case setHasNext(Bool)
        case setCurrentPage
        case setCompanies([FollowedCompany])
        case checkNeedToLoadNext(FollowedCompany)
        case handleError(Error)
    }
    
    @Dependency(\.homeService) var homeService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return.none
                
            case .viewInit:
                guard state.needInitialLoad else { return .none }
                state.needInitialLoad = false
                
                return .send(.loadNext)
                
            case .loadNext:
                guard !state.isLoading else { return .none }
                
                state.isLoading = true
                return .run {
                    [
                        hasNext = state.hasNext,
                        currentPage = state.currentPage
                    ] send in
                    guard hasNext else {
                        await send(.setIsLoading(false))
                        return
                    }
                    
                    let data = try await homeService.fetchFollowedCompanies(page: currentPage)
                    let companies = data.companies.map { $0.toDomain() }
                    
                    await send(.setHasNext(data.hasNext))
                    await send(.setCompanies(companies))
                    await send(.setIsLoading(false))
                } catch: { error, send in
                    await send(.handleError(error))
                }
                
            case let .setIsLoading(isLoading):
                state.isLoading = isLoading
                
                return .none
                
            case let .setHasNext(hasNext):
                state.hasNext = hasNext
                
                return .send(.setCurrentPage)
                
            case .setCurrentPage:
                if state.hasNext {
                    state.currentPage += 1
                }
                
                return .none
                
            case let .setCompanies(companies):
                state.companies += companies
                return .none
                
            case let .checkNeedToLoadNext(company):
                guard let index = state.companies.lastIndex(of: company) else { return .none }
                
                if index == state.companies.count - 2 {
                    return .send(.loadNext)
                } else {
                    return .none
                }
                
            case let .handleError(error):
                if let failResponse = error as? FailResponse {
                    state.error = failResponse
                    state.isAlertShowing = true
                    return .none
                } else {
                    print("❌ error: \(error)")
                    return .none
                }
            }
        }
    }
}

struct FollowedCompanyTabView: View {
    @Bindable var store: StoreOf<FollowedCompanyTabFeature>
    
    init(store: StoreOf<FollowedCompanyTabFeature>) {
        self.store = store
        store.send(.viewInit)
    }
    
    var body: some View {
        if store.companies.isEmpty {
            empty
                .appAlert($store.isAlertShowing, isSuccess: false, message: store.error?.message ?? "")
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(store.companies) { company in
                        VStack(spacing: 0) {
                            NavigationLink(
                                state: UpFeature.Path.State.detail(
                                    CompanyDetailFeature.State(
                                        companyID: company.id
                                    )
                                )
                            ) {
                                FollowedCompanyCardView(company: company)
                            }
                            Divider()
                        }
                        .onAppear {
                            store.send(.checkNeedToLoadNext(company))
                        }
                    }
                }
            }
            .appAlert($store.isAlertShowing, isSuccess: false, message: store.error?.message ?? "")
        }
    }
    
    private var empty: some View {
        VStack(spacing: 12) {
            Spacer()
            AppIcon.followingFill.image(
                width: 48,
                height: 48,
                appColor: .gray30
            )
            Text("팔로우 한 업체가 없습니다.")
                .pretendard(.body1Regular, color: .gray50)
            Spacer()
        }
    }
}

#Preview {
    FollowedCompanyTabView(
        store: Store(
            initialState: FollowedCompanyTabFeature.State()
        ) {
            FollowedCompanyTabFeature()
        }
    )
}
