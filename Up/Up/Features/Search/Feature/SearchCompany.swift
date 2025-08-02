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
        var currentLocation: Location = .default
        var search: Search.State? = .idle(SearchIdleFeature.State())
        var searchState: SearchState = .idle
        var searchTerm: String = ""
        var searchTheme: SearchTheme = .keyword
        var isFocused: Bool = false
        var proposedCompanies: [ProposedCompany] = []
        var savedCompanies: [SavedCompany] = []
        var isAlertShowing = false
        var error: FailResponse?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case viewAppear
        case requestCurrentLocation
        case currentLocationFetched(Location)
        case backButtonTapped
        case textFieldFocused
        case clearButtonTapped
        case cancelButtonTapped
        case enterButtonTapped
        case search(Search.Action)
        case termChanged
        case fetchProposedCompanies
        case setProposedCompanies([ProposedCompany])
        case loadSavedCompanies
        case setSearchState(SearchState)
        case handleError(Error)
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
    @Dependency(\.userDefaultsService) var userDefaultsService
    @Dependency(\.searchService) var searchService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .viewAppear:
                return .send(.loadSavedCompanies)
                
            case .requestCurrentLocation:
                return .run { send in
                    let location = try await LocationService.shared.requestCurrentLocation()
                    
                    let current = location.toDomain()
                    await send(.currentLocationFetched(current))
                } catch: { error, send in
                    print("error: \(error)")
                }
                
            case let .currentLocationFetched(location):
                state.currentLocation = location
                
                return .none
            case .backButtonTapped:
                return .run { _ in await dismiss() }
                
            case .textFieldFocused:
                state.proposedCompanies = []
                state.isFocused = true
                return .run { send in
                    await send(.fetchProposedCompanies)
                    await send(.setSearchState(.focused))
                }
                
            case .clearButtonTapped:
                return .send(.textFieldFocused)
                
            case .cancelButtonTapped:
                state.isFocused = false
                return .send(.setSearchState(.idle))
                
            case .enterButtonTapped:
                let searchTerm = RecentSearchTerm(searchTerm: state.searchTerm)
                var searchTerms = [RecentSearchTerm]()
                
                if let recentSearchTerms = try? userDefaultsService.fetch(key: "recentSearchTerms", type: [RecentSearchTerm].self) {
                    searchTerms = recentSearchTerms
                }
                
                if let index = searchTerms.firstIndex(where: { $0.searchTerm == searchTerm.searchTerm }) {
                    searchTerms.remove(at: index)
                }
                
                if searchTerms.count == 10 {
                    searchTerms.removeLast()
                }
                
                searchTerms.insert(searchTerm, at: 0)
                try? userDefaultsService.save(key: .recentSearchTerms, value: searchTerms)
                
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
                
            case let .search(.submitted(.delegate(.alert(error)))):
                return .send(.handleError(error))
                
            case .search:
                return .none
                
            case .termChanged:
                return .run { [state] send in
                    guard state.searchState == .focused else {
                        return
                    }
                    if state.searchTerm.isEmpty {
                        await send(.setSearchState(.focused))
                    } else {
                        await send(.fetchProposedCompanies)
                    }
                }
                .debounce(
                    id: CancelID.debounce,
                    for: 0.5,
                    scheduler: mainQueue
                )
                
            case .fetchProposedCompanies:
                return .run { [state] send in
                    let data = try await searchService.fetchProposedCompanies(
                        keyword: state.searchTerm,
                        latitude: state.currentLocation.lat,
                        longitude: state.currentLocation.lng
                    )
                    let companies = data.companies.map { $0.toDomain() }
                    
                    guard state.searchState == .focused else {
                        return
                    }
                    
                    await send(.setProposedCompanies(companies))
                } catch: { error, send in
                    await send(.handleError(error))
                }
                
            case let .setProposedCompanies(companies):
                state.proposedCompanies = companies
                return .send(.setSearchState(.focused))
                
            case .loadSavedCompanies:
                if let savedCompanies = try? userDefaultsService.fetch(key: "savedCompanies", type: [SavedCompany].self) {
                    state.savedCompanies = savedCompanies
                }
                return .none
                
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
                            proposedCompanies: state.proposedCompanies,
                            savedCompanies: state.savedCompanies
                        )
                    )
                case .submitted:
                    state.search = .submitted(
                        SearchSubmittedFeature.State(
                            searchTerm: state.searchTerm,
                            searchTheme: state.searchTheme,
                            currentLocation: state.currentLocation
                        )
                    )
                }
                state.searchState = searchState
                return .none
                
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
                IconButton(
                    icon: .arrowLeft) {
                        store.send(.backButtonTapped)
                    }
            }
            ToolbarItem(placement: .principal) {
                Text("업체 검색")
                    .pretendard(.h2, color: .gray90)
            }
        }
        .appAlert($store.isAlertShowing, isSuccess: false, message: store.error?.message ?? "")
        .onAppear {
            store.send(.viewAppear)
        }
    }
    
    private var enterSearchTermArea: some View {
        HStack(spacing: 16) {
            backButton
            UPTextField(
                text: $store.searchTerm,
                isFocused: $store.isFocused,
                placeholder: "상호명으로 검색하기",
                leftComponent: .icon(appIcon: .searchLine, size: 24, color: .gray90),
                rightComponent: .clear {
                    store.send(.clearButtonTapped)
                }
            ) {  _, isFocused in
                if isFocused {
                    store.send(.textFieldFocused)
                }
            } onTextChange: { _, _ in
                store.send(.termChanged)
            }
            .onSubmit {
                store.send(.enterButtonTapped)
            }
            cancelButton
        }
        .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
    }
    
    @ViewBuilder
    private var backButton: some View {
        if store.searchState == .submitted {
            IconButton(icon: .arrowLeft) {
                store.send(.backButtonTapped)
            }
        }
    }
    
    @ViewBuilder
    private var cancelButton: some View {
        if store.searchState == .focused {
            Button {
                store.send(.cancelButtonTapped)
            } label: {
                Text("취소")
                    .pretendard(.body1Regular, color: .gray90)
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
