//
//  SearchFocused.swift
//  Up
//
//  Created by Jun Young Lee on 6/7/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct SearchFocusedFeature {
    @ObservableState
    struct State: Equatable {
        let searchTerm: String
        let proposedCompanies: [ProposedCompany]
        var savedCompanies: [SavedCompany] = []
    }
    
    enum Action {
        case viewAppear
        case loadSavedCompanies
        case deleteButtonTapped(SavedCompany)
    }
    
    @Dependency(\.userDefaultsService) var userDefaultsService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewAppear:
                return .send(.loadSavedCompanies)
                
            case .loadSavedCompanies:
                if let savedCompanies = try? userDefaultsService.fetch(key: "savedCompanies", type: [SavedCompany].self) {
                    state.savedCompanies = savedCompanies
                }
                return .none
                
            case let .deleteButtonTapped(company):
                if let index = state.savedCompanies.firstIndex(of: company) {
                    state.savedCompanies.remove(at: index)
                }
                
                try? userDefaultsService.save(key: "savedCompanies", value: state.savedCompanies)
                
                return .none
            }
        }
    }
}

struct SearchFocusedView: View {
    let store: StoreOf<SearchFocusedFeature>
    
    var body: some View {
        searchFocused
            .onAppear {
                store.send(.viewAppear)
            }
    }
    
    @ViewBuilder
    private var searchFocused: some View {
        if store.searchTerm.isEmpty {
            recentSearchedCompany
        } else {
            searchedCompany
        }
    }
    
    @ViewBuilder
    private var recentSearchedCompany: some View {
        if store.savedCompanies.isEmpty {
            emptyRecent
        } else {
            ScrollView {
                LazyVStack {
                    Divider()
                    ForEach(store.savedCompanies) { company in
                        NavigationLink(
                            state: UpFeature.MainPath.State.detail(
                                CompanyDetailFeature.State(
                                    companyID: company.id
                                )
                            )
                        ) {
                            savedCompanyButton(company)
                        }
                    }
                }
            }
        }
    }
    
    private var emptyRecent: some View {
        VStack(spacing: 12) {
            Spacer()
            AppIcon.infoFill.image(
                width: 48,
                height: 48,
                appColor: .gray30
            )
            Text("최근 검색한 기록이 없습니다.")
                .pretendard(.body1Regular, color: .gray50)
            Spacer()
        }
    }
    
    private func savedCompanyButton(_ company: SavedCompany) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                HStack(alignment: .top, spacing: 4) {
                    AppIcon.clockLine.image(
                        width: 20,
                        height: 20,
                        appColor: .gray30
                    )
                    VStack(alignment: .leading, spacing: 8) {
                        Text(company.name)
                            .pretendard(.body1Bold, color: .gray90)
                        Text(company.address)
                            .pretendard(.captionRegular, color: .gray50)
                    }
                    .multilineTextAlignment(.leading)
                }
                Spacer()
                Button {
                    store.send(.deleteButtonTapped(company))
                } label: {
                    AppIcon.closeLine.image(
                        width: 20,
                        height: 20,
                        appColor: .gray50
                    )
                }
            }
            .padding(20)
            Divider()
        }
    }
    
    @ViewBuilder
    private var searchedCompany: some View {
        if store.proposedCompanies.isEmpty {
            emptyProposed
        } else {
            ScrollView {
                LazyVStack {
                    Divider()
                    ForEach(store.proposedCompanies) { company in
                        NavigationLink(
                            state: UpFeature.MainPath.State.detail(
                                CompanyDetailFeature.State(
                                    companyID: company.id
                                )
                            )
                        ) {
                            proposedCompanyButton(company)
                        }
                    }
                }
            }
        }
    }
    
    private var emptyProposed: some View {
        VStack(spacing: 12) {
            Spacer()
            AppIcon.searchLine.image(
                width: 48,
                height: 48,
                appColor: .gray30
            )
            Text("검색 결과를 찾을 수 없습니다.")
                .pretendard(.body1Regular, color: .gray50)
            Spacer()
        }
    }
    
    private func proposedCompanyButton(_ company: ProposedCompany) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 4) {
                AppIcon.searchLine.image(
                    width: 20,
                    height: 20,
                    appColor: .gray30
                )
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 4) {
                        Text(company.name)
                            .pretendard(.body1Bold, color: .gray90)
                        AppIcon.starFill.image(
                            width: 20,
                            height: 20,
                            appColor: .seYellow40
                        )
                        Text(String(company.totalRating.rounded(to: 1)))
                            .pretendard(.body1Bold, color: .gray90)
                        Spacer()
                    }
                    Text(company.address)
                        .pretendard(.captionRegular, color: .gray50)
                }
                .multilineTextAlignment(.leading)
            }
            .padding(20)
            Divider()
        }
    }
}

#Preview {
    NavigationStack {
        SearchFocusedView(
            store: Store(
                initialState: SearchFocusedFeature.State(
                    searchTerm: "포레",
                    proposedCompanies: [
                        ProposedCompany(
                            id: 1,
                            name: "포레스트병원",
                            address: "서울특별시 종로구 율곡로 164, 지하1,2층,1층일부,2~8층 (원남동)",
                            totalRating: 3.3
                        )
                    ],
                    savedCompanies: [
                        SavedCompany(
                            id: 1,
                            name: "포레스트병원",
                            address: "서울특별시 종로구 율곡로 164, 지하1,2층,1층일부,2~8층 (원남동)"
                        )
                    ]
                )
            ) {
                SearchFocusedFeature()
            }
        )
    }
}
