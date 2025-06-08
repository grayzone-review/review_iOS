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
        let searchedCompanies: [SearchedCompany]
        var recentSearchedCompanies: [SearchedCompany] = []
    }

    enum Action {
        case appear
        case deleteButtonTapped(SearchedCompany)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appear:
                if let data = UserDefaults.standard.data(forKey: "recentSearchedCompanies"),
                   let recentSearchedCompanies = try? JSONDecoder().decode([SearchedCompany].self, from: data) {
                    state.recentSearchedCompanies = recentSearchedCompanies
                }
                
                return .none
                
            case let .deleteButtonTapped(company):
                if let index = state.recentSearchedCompanies.firstIndex(of: company) {
                    state.recentSearchedCompanies.remove(at: index)
                }
                
                if let data = try? JSONEncoder().encode(state.recentSearchedCompanies) {
                    UserDefaults.standard.set(data, forKey: "recentSearchedCompanies")
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
        store.send(.appear)
    }

    var body: some View {
        if store.searchTerm.isEmpty {
            recentSearchedCompany
        } else {
            searchedCompany
        }
    }
    
    @ViewBuilder
    private var recentSearchedCompany: some View {
        if store.recentSearchedCompanies.isEmpty {
            empty
        } else {
            ScrollView {
                LazyVStack {
                    Divider()
                    ForEach(store.recentSearchedCompanies) { company in
                        NavigationLink(
                            state: UpFeature.Path.State.detail(
                                CompanyDetailFeature.State(
                                    companyID: company.id,
                                    searchedCompany: company
                                )
                            )
                        ) {
                            recentSearchCompanyButton(company)
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
    
    private func recentSearchCompanyButton(_ company: SearchedCompany) -> some View {
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
                ForEach(store.searchedCompanies) { company in
                    NavigationLink(
                        state: UpFeature.Path.State.detail(
                            CompanyDetailFeature.State(
                                companyID: company.id,
                                searchedCompany: company
                            )
                        )
                    ) {
                        searchCompanyButton(company)
                    }
                }
            }
        }
    }
    
    private func searchCompanyButton(_ company: SearchedCompany) -> some View {
        var attributedString = AttributedString(company.name)
        
        attributedString.foregroundColor = AppColor.gray90.color
        attributedString.font = Typography.body1Bold.font
        
        if let range = attributedString.range(of: store.searchTerm) {
            attributedString[range].foregroundColor = AppColor.orange40.color
        }
        
        return VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    AppIcon.searchLine.image
                        .foregroundStyle(AppColor.gray30.color)
                        .frame(width: 20, height: 20)
                    Text(attributedString)
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
                    searchedCompanies: [
                        SearchedCompany(
                            id: 1,
                            name: "포레스트병원",
                            address: "서울특별시 종로구 율곡로 164, 지하1,2층,1층일부,2~8층 (원남동)",
                            totalRating: 3.3
                        )
                    ],
                    recentSearchedCompanies: [
                        SearchedCompany(
                            id: 1,
                            name: "포레스트병원",
                            address: "서울특별시 종로구 율곡로 164, 지하1,2층,1층일부,2~8층 (원남동)",
                            totalRating: 3.3
                        )
                    ]
                )
            ) {
                SearchFocusedFeature()
            }
        )
    }
}
