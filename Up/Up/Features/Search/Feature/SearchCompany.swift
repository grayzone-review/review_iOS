//
//  SearchCompany.swift
//  Up
//
//  Created by Jun Young Lee on 6/5/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct SearchCompanyFeature {
    @ObservableState
    struct State: Equatable {
        var search: Search.State? = .idle(SearchIdleFeature.State())
        var searchState: SearchState = .idle
        var searchTerm: String = ""
        var searchTheme: SearchTheme = .keyword
        var isFocused: Bool = false
        var searchedCompanies: [SearchedCompany] = []
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case backButtonTapped
        case textFieldFocused
        case clearButtonTapped
        case cancelButtonTapped
        case enterButtonTapped
        case search(Search.Action)
        case termChanged
        case fetchRelatedCompanies
        case setSearchState(SearchState)
    }
    
    @Reducer
    enum Search {
        case idle(SearchIdleFeature)
        case focused(SearchFocusedFeature)
        case submitted(SearchSubmittedFeature)
    }
    
    enum CancelID {
        case debounce
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.mainQueue) var mainQueue
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return.none
                
            case .backButtonTapped:
                return .run { _ in await dismiss() }
                
            case .textFieldFocused:
                return .send(.setSearchState(.focused))
                
            case .clearButtonTapped:
                state.searchTerm = ""
                return .send(.textFieldFocused)
                
            case .cancelButtonTapped:
                state.searchTerm = ""
                state.isFocused = false
                return .send(.setSearchState(.idle))
                
            case .enterButtonTapped:
                let searchTerm = RecentSearchTerm(searchTerm: state.searchTerm)
                var searchTerms = [RecentSearchTerm]()
                
                if let data = UserDefaults.standard.data(forKey: "recentSearchTerms"),
                   let recentSearchTerms = try? JSONDecoder().decode([RecentSearchTerm].self, from: data) {
                    searchTerms = recentSearchTerms
                }
                if let index = searchTerms.firstIndex(where: { $0.searchTerm == searchTerm.searchTerm }) {
                    searchTerms.remove(at: index)
                }
                if searchTerms.count == 10 {
                    searchTerms.removeLast()
                }
                
                searchTerms.insert(searchTerm, at: 0)
                
                if let data = try? JSONEncoder().encode(searchTerms) {
                    UserDefaults.standard.set(data, forKey: "recentSearchTerms")
                }
                
                state.searchTheme = .keyword
                return .send(.setSearchState(.submitted))
                
            case let .search(.idle(.delegate(.search(searchTerm, searchTheme)))):
                state.searchTheme = searchTheme
                state.searchTerm = searchTerm
                return .send(.setSearchState(.submitted))
                
            case let .search(.submitted(.delegate(.search(searchTerm, searchTheme)))):
                state.searchTheme = searchTheme
                state.searchTerm = searchTerm
                return .send(.setSearchState(.submitted))
                
            case .search:
                return .none
                
            case .termChanged:
                return .send(.fetchRelatedCompanies)
                    .debounce(
                        id: CancelID.debounce,
                        for: 0.5,
                        scheduler: mainQueue
                    )
                
            case .fetchRelatedCompanies:
                guard state.searchState == .focused else {
                    return .none
                }
                
                state.searchedCompanies = [
                    SearchedCompany(
                        id: 1,
                        name: "포레스트병원",
                        address: "서울특별시 종로구 율곡로 164, 지하1,2층,1층일부,2~8층 (원남동)",
                        totalRating: 3.3,
                        isFollowed: false,
                        distance: "서울 · 0.8km",
                        title: "복지가 좋고 경력 쌓기에 좋은 회사"
                    )
                ] // service 구현 이후 호출결과로 변경
                return .send(.setSearchState(.focused))
                
            case let .setSearchState(searchState):
                switch searchState {
                case .idle:
                    if state.searchState != .idle {
                        state.search = .idle(SearchIdleFeature.State())
                    }
                case .focused:
                    state.search = .focused(
                        SearchFocusedFeature.State(
                            searchTerm: state.searchTerm,
                            searchedCompanies: state.searchedCompanies
                        )
                    )
                case .submitted:
                    state.search = .submitted(
                        SearchSubmittedFeature.State(
                            searchTerm: state.searchTerm,
                            searchTheme: state.searchTheme
                        )
                    )
                }
                state.searchState = searchState
                return .none
            }
        }
        .ifLet(\.search, action: \.search) {
            Search.body
        }
    }
}

extension SearchCompanyFeature.Search.State: Equatable {}

struct SearchCompanyView: View {
    @Bindable var store: StoreOf<SearchCompanyFeature>
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            enterSearchTermArea
            bodyArea
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(store.searchState == .idle ? .visible : .hidden)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    store.send(.backButtonTapped)
                } label: {
                    AppIcon.arrowLeft.image
                        .foregroundStyle(AppColor.gray90.color)
                        .frame(width: 24, height: 24)
                        .padding(10)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("업체 검색")
                    .pretendard(.h2, color: .gray90)
            }
        }
    }
    
    private var enterSearchTermArea: some View {
        HStack(spacing: 8) { // 추후 디자인 확정되면 버튼과 함께 간격 수정
            HStack(spacing: 8) {
                searchIcon
                textField
                clearButton
            }
            .padding(16)
            .frame(height: 52)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(store.searchState == .focused ? AppColor.gray90.color : AppColor.gray20.color)
            }
            
            cancelButton
        }
        .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
    }
    
    private var searchIcon: some View {
        AppIcon.searchLine.image
            .foregroundStyle(AppColor.gray90.color)
            .frame(width: 24, height: 24)
    }
    
    private var textField: some View {
        TextField(
            "상호명으로 검색하기",
            text: $store.searchTerm
        )
        .focused($isFocused)
        .bind($store.isFocused, to: $isFocused)
        .lineLimit(1)
        .pretendard(.body1Regular, color: .gray90)
        .onChange(of: isFocused) { _, isFocused in
            if isFocused {
                store.send(.textFieldFocused)
            }
        }
        .onChange(of: store.searchTerm) { _, _ in
            store.send(.termChanged)
        }
        .onSubmit {
            store.send(.enterButtonTapped)
        }
    }
    
    @ViewBuilder
    private var clearButton: some View {
        if store.searchState != .idle {
            Button {
                store.send(.clearButtonTapped)
            } label: {
                AppIcon.closeFill.image
                    .foregroundStyle(AppColor.gray10.color)
                    .frame(width: 24, height: 24)
                    .overlay {
                        AppIcon.closeLine.image
                            .foregroundStyle(AppColor.gray50.color)
                            .frame(width: 16, height: 16)
                    }
            }
        }
    }
    
    @ViewBuilder
    private var cancelButton: some View {
        if store.searchState != .idle {
            Button {
                store.send(.cancelButtonTapped)
            } label: {
                Text("취소") // 디자인 수정되면 변경 필요
            }
        }
    }
    
    @ViewBuilder
    private var bodyArea: some View {
        switch store.searchState {
        case .idle:
            if let idleStore = store.scope(state: \.search?.idle, action: \.search.idle) {
                SearchIdleView(store: idleStore)
            }
        case .focused:
            if let focusedStore = store.scope(state: \.search?.focused, action: \.search.focused) {
                SearchFocusedView(store: focusedStore)
            }
        case .submitted:
            if let submittedStore = store.scope(state: \.search?.submitted, action: \.search.submitted) {
                SearchSubmittedView(store: submittedStore)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SearchCompanyView(
            store: Store(
                initialState: SearchCompanyFeature.State()
            ) {
                SearchCompanyFeature()
            }
        )
    }
}
