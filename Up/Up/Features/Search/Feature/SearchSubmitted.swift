//
//  SearchSubmitted.swift
//  Up
//
//  Created by Jun Young Lee on 6/8/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct SearchSubmittedFeature {
    @ObservableState
    struct State: Equatable {
        let searchTerm: String
        let searchTheme: SearchTheme
        var needLoad: Bool = true
        var searchedCompanies: [SearchedCompany] = []
    }
    
    enum Action {
        case viewInit
        case delegate(Delegate)
        case themeButtonTapped(SearchTheme)
        case followButtonTapped(SearchedCompany)
        case follow(id: Int, isFollowed: Bool)
        
        enum Delegate: Equatable {
            case search(String, SearchTheme)
        }
    }
    
    enum CancelID: Hashable {
        case follow(id: Int)
    }
    
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.companyService) var companyService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewInit:
                // service 정의 후 검색결과 로딩 API 호출 예정
                state.searchedCompanies = [
                    SearchedCompany(
                        id: 1,
                        name: "스타벅스 석촌역점",
                        address: "서울특별시 송파구 백제고분로 358 1층",
                        totalRating: 4.0,
                        isFollowed: false,
                        distance: "서울 · 0.8km",
                        title: "복지가 좋고 경력 쌓기에 좋은 회사"
                    )
                ]
                return .none
                
            case .delegate:
                return .none
                
            case let .themeButtonTapped(searchTheme):
                return .send(.delegate(.search("#\(searchTheme.text)", searchTheme)))
                
            case let .followButtonTapped(company):
                guard let index = state.searchedCompanies.firstIndex(where: { $0.id == company.id }) else {
                    return .none
                }
                
                state.searchedCompanies[index].isFollowed.toggle()
                return .send(.follow(id: company.id, isFollowed: state.searchedCompanies[index].isFollowed))
                    .debounce(
                        id: CancelID.follow(id: company.id),
                        for: 1,
                        scheduler: mainQueue
                    )
                
            case let .follow(id, isFollowed):
                return .run { _ in
                    if isFollowed {
                        try await companyService.createCompanyFollowing(of: id)
                    } else {
                        try await companyService.deleteCompanyFollowing(of: id)
                    }
                }
            }
        }
    }
}

struct SearchSubmittedView: View {
    @Bindable var store: StoreOf<SearchSubmittedFeature>
    
    init(store: StoreOf<SearchSubmittedFeature>) {
        self.store = store
        store.send(.viewInit)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            searchTheme
            resultCount
            searchResult
        }
    }
    
    @ViewBuilder
    private var searchTheme: some View {
        if store.searchTheme != .keyword {
            VStack(spacing: 0) {
                Divider()
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        Text("모아보기")
                            .pretendard(.body2Bold, color: .gray90)
                        themeButton(.near)
                        themeButton(.neighborhood)
                        themeButton(.interest)
                    }
                    .padding(
                        EdgeInsets(
                            top: 10,
                            leading: 20,
                            bottom: 10,
                            trailing: 20
                        )
                    )
                }
                .scrollIndicators(.hidden)
                Divider()
            }
            .background(AppColor.gray10.color)
        }
    }
    
    @ViewBuilder
    private func themeButton(_ searchTheme: SearchTheme) -> some View {
        Button {
            store.send(.themeButtonTapped(searchTheme))
        } label: {
            HStack(spacing: 6) {
                switch searchTheme {
                case .near:
                    (searchTheme == store.searchTheme ? AppImage.mymapFill.image : AppImage.mymapLine.image)
                        .frame(width: 18, height: 18)
                case .neighborhood:
                    (searchTheme == store.searchTheme ? AppImage.myplaceFill.image : AppImage.myplaceLine.image)
                        .frame(width: 18, height: 18)
                case .interest:
                    (searchTheme == store.searchTheme ? AppImage.intersetFill.image : AppImage.intersetLine.image)
                        .frame(width: 18, height: 18)
                default:
                    EmptyView()
                }
                Text(searchTheme.text)
                    .pretendard(.captionSemiBold, color: searchTheme == store.searchTheme ? .white : .gray70)
            }
            .frame(width: 120, height: 40)
            .background(searchTheme == store.searchTheme ? AppColor.orange40.color : AppColor.white.color)
            .clipShape(RoundedRectangle(cornerRadius: 100))
            .overlay {
                RoundedRectangle(cornerRadius: 100)
                    .stroke(searchTheme == store.searchTheme ? AppColor.orange40.color : AppColor.gray20.color)
            }
        }
    }
    
    private var resultCount: some View {
        HStack(spacing: 8) {
            Text("검색 결과")
                .pretendard(.h3, color: .gray90)
            Text("\(store.searchedCompanies.count)")
                .pretendard(.h3, color: .gray50)
            Spacer()
        }
        .padding(
            EdgeInsets(
                top: 16,
                leading: 20,
                bottom: 16,
                trailing: 20
            )
        )
    }
    
    @ViewBuilder
    private var searchResult: some View {
        if store.searchedCompanies.isEmpty {
            empty
        } else {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(store.searchedCompanies) { company in
                    NavigationLink(
                        state: UpFeature.Path.State.detail(
                            CompanyDetailFeature.State(
                                companyID: company.id,
                                searchedCompany: company
                            )
                        )
                    ) {
                            searchedCompany(company)
                        }
                    }
                }
                .padding([.horizontal, .bottom], 20)
            }
        }
    }
    
    private var empty: some View {
        VStack(spacing: 12) {
            Spacer()
            AppIcon.searchLine.image
                .foregroundStyle(AppColor.gray30.color)
                .frame(width: 48, height: 48)
            
            Text("검색 결과를 찾을 수 없습니다.")
                .pretendard(.body1Regular, color: .gray50)
            Spacer()
        }
    }
    
    private func searchedCompany(_ company: SearchedCompany) -> some View {
        VStack(spacing: 40) {
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(company.name)
                        .pretendard(.body1Bold, color: .black)
                    Text(company.address)
                        .pretendard(.captionRegular, color: .gray50)
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            AppIcon.starFill.image
                                .foregroundStyle(AppColor.seYellow40.color)
                                .frame(width: 16, height: 16)
                            Text(String(company.totalRating.rounded(to: 1)))
                                .pretendard(.captionBold, color: .gray90)
                        }
                        
                        Text(company.distance)
                            .pretendard(.captionRegular, color: .gray50)
                    }
                }
                Spacer()
                followButton(company)
            }
            
            HStack(spacing: 8) {
                Text("한줄평")
                    .pretendard(.captionBold, color: .gray50)
                    .padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                    .background(AppColor.gray10.color)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                Text(company.title)
                    .pretendard(.captionRegular, color: .gray70)
                Spacer()
            }
        }
        .padding(20)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColor.gray20.color)
        )
    }
    
    @ViewBuilder
    private func followButton(_ company: SearchedCompany) -> some View {
        Button {
            store.send(.followButtonTapped(company))
        } label: {
            if company.isFollowed {
                following
            } else {
                follow
            }
        }
    }
    
    private var following: some View {
        AppIcon.followingFill.image
            .foregroundStyle(AppColor.white.color)
            .frame(width: 24, height: 24)
            .padding(4)
            .background(AppColor.orange40.color)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var follow: some View {
        AppIcon.followLine.image
            .foregroundStyle(AppColor.orange40.color)
            .frame(width: 24, height: 24)
            .padding(4)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColor.orange40.color)
            }
    }
}

#Preview {
    SearchSubmittedView(
        store: Store(
            initialState: SearchSubmittedFeature.State(
                searchTerm: "",
                searchTheme: .near
            )
        ) {
            SearchSubmittedFeature()
        }
    )
}
