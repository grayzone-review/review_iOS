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
        var needLoad: Bool = true
    }

    enum Action {
        case viewInit
        case viewAppear
        case loadSavedCompanies
        case deleteButtonTapped(SavedCompany)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewInit:
                guard state.needLoad else {
                    return .none
                }
                
                state.needLoad = false
                
                return .run { send in
                    await send(.loadSavedCompanies)
                }
                
            case .viewAppear:
                return .send(.loadSavedCompanies)
                
            case .loadSavedCompanies:
                if let data = UserDefaults.standard.data(forKey: "savedCompanies"),
                   let savedCompanies = try? JSONDecoder().decode([SavedCompany].self, from: data) {
                    state.savedCompanies = savedCompanies
                }
                return .none
                
            case let .deleteButtonTapped(company):
                if let index = state.savedCompanies.firstIndex(of: company) {
                    state.savedCompanies.remove(at: index)
                }
                
                if let data = try? JSONEncoder().encode(state.savedCompanies) {
                    UserDefaults.standard.set(data, forKey: "savedCompanies")
                }
                
                
                return .none
            }
        }
    }
}

struct SearchFocusedView: View {
    @Bindable var store: StoreOf<SearchFocusedFeature>
    
    init(store: StoreOf<SearchFocusedFeature>) {
        self.store = store
        store.send(.viewInit)
    }

    var body: some View {
        if store.searchTerm.isEmpty {
            recentSearchedCompany
                .onAppear {
                    store.send(.viewAppear)
                }
        } else {
            searchedCompany
        }
    }
    
    @ViewBuilder
    private var recentSearchedCompany: some View {
        if store.savedCompanies.isEmpty {
            empty
        } else {
            ScrollView {
                LazyVStack {
                    Divider()
                    ForEach(store.savedCompanies) { company in
                        NavigationLink(
                            state: UpFeature.Path.State.detail(
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
    
    private var empty: some View {
        VStack(spacing: 12) {
            Spacer()
            AppIcon.infoFill.image
                .foregroundStyle(AppColor.gray30.color)
                .frame(width: 48, height: 48)
            
            Text("최근 검색한 기록이 없습니다.")
                .pretendard(.body1Regular, color: .gray50)
            Spacer()
        }
    }
    
    private func savedCompanyButton(_ company: SavedCompany) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 4) {
                        AppIcon.clockLine.image
                            .foregroundStyle(AppColor.gray30.color)
                            .frame(width: 20, height: 20)
                        Text(company.name)
                            .pretendard(.body1Bold, color: .gray90)
                        Spacer()
                    }
                    Text(company.address)
                        .pretendard(.captionRegular, color: .gray50)
                }
                Button {
                    store.send(.deleteButtonTapped(company))
                } label: {
                    AppIcon.closeLine.image
                        .foregroundStyle(AppColor.gray50.color)
                        .frame(width: 20, height: 20)
                }
            }
            .padding(20)
            Divider()
        }
    }
    
    private var searchedCompany: some View {
        ScrollView {
            LazyVStack {
                Divider()
                ForEach(store.proposedCompanies) { company in
                    NavigationLink(
                        state: UpFeature.Path.State.detail(
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
    
    private func proposedCompanyButton(_ company: ProposedCompany) -> some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    AppIcon.searchLine.image
                        .foregroundStyle(AppColor.gray30.color)
                        .frame(width: 20, height: 20)
                    Text(company.name)
                        .pretendard(.body1Bold, color: .gray90)
                    AppIcon.starFill.image
                        .foregroundStyle(AppColor.seYellow40.color)
                        .frame(width: 20, height: 20)
                    
                    Text(String(company.totalRating.rounded(to: 1)))
                        .pretendard(.body1Bold, color: .gray90)
                    Spacer()
                }
                Text(company.address)
                    .pretendard(.captionRegular, color: .gray50)
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
                    ], needLoad: true
                )
            ) {
                SearchFocusedFeature()
            }
        )
    }
}
