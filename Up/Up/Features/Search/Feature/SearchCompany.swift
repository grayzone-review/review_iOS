//
//  SearchCompany.swift
//  Up
//
//  Created by Jun Young Lee on 6/5/25.
//

import ComposableArchitecture
import SwiftUI
import SwiftData

@Reducer
struct SearchCompanyFeature {
    @ObservableState
    struct State: Equatable {
        var search: Search.State?
        var searchState: SearchState = .idle
        var searchTerm: String = ""
        var searchTheme: SearchTheme = .keyword
        var isFocused: Bool = false
        var recentSearchTerms: [RecentSearchTerm] = []
    }
    
    enum Action: BindableAction {
        case appear(ModelContext)
        case binding(BindingAction<State>)
        case backButtonTapped
        case textFieldFocused
        case clearButtonTapped
        case cancelButtonTapped
        case enterButtonTapped(ModelContext)
        case search(Search.Action)
        case termChanged
        case fetchRelatedCompanies
        case setSearchState(SearchState)
    }
    
    @Reducer
    enum Search {
        case idle(SearchIdleFeature)
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
            case let .appear(modelContext):
                do {
                    state.recentSearchTerms = try modelContext.fetch(FetchDescriptor<RecentSearchTerm>())
                    return .send(.setSearchState(.idle))
                } catch {
                    fatalError("RecentSearchTerm 조회 실패: \(error)")
                }
                
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
                
            case let .enterButtonTapped(modelContext):
                if let existing = state.recentSearchTerms.first(where:{ $0.searchTerm == state.searchTerm }) {
                    existing.creationDate = .now
                } else {
                    if state.recentSearchTerms.count == 10 {
                        let last = state.recentSearchTerms.removeLast()
                        modelContext.delete(last)
                    }
                    let newSearchTerm = RecentSearchTerm(searchTerm: state.searchTerm)
                    state.recentSearchTerms.insert(
                        newSearchTerm,
                        at: 0
                    )
                    modelContext.insert(newSearchTerm)
                }
                
                try? modelContext.save()
                state.searchTheme = .keyword
                return .send(.setSearchState(.submitted))
                
            case let .search(.idle(.delegate(.search(searchTerm, searchTheme)))):
                state.searchTheme = searchTheme
                state.searchTerm = searchTerm
                return .send(.setSearchState(.submitted))
                
            case let .search(.idle(.delegate(.updateRecentSearchTerms(searchTerms)))):
                state.recentSearchTerms = searchTerms
                return .none
                
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
                return .none // service 구현 이후 연관 검색어 API 호출로 변경 필요
                
            case let .setSearchState(searchState):
                state.searchState = searchState
                switch searchState {
                case .idle:
                    state.search = .idle(SearchIdleFeature.State(recentSearchTerms: state.recentSearchTerms))
                case .focused:
                    state.search = nil // focused 관련 작업 후 수정 예정
                case .submitted:
                    state.search = nil // submitted 관련 작업 후 수정 예정
                }
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
    @Environment(\.modelContext) var modelContext
    
    init(store: StoreOf<SearchCompanyFeature>) {
        self.store = store
        store.send(.appear(modelContext))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            enterSearchTermArea
            ScrollView {
                bodyArea
            }
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
                    .stroke(AppColor.gray20.color)
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
            store.send(.enterButtonTapped(modelContext))
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
        default:
            EmptyView()
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
