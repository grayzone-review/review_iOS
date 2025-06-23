//
//  SearchIdle.swift
//  Up
//
//  Created by Jun Young Lee on 6/6/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct SearchIdleFeature {
    @ObservableState
    struct State: Equatable {
        var recentSearchTerms: [RecentSearchTerm] = []
        var needLoad: Bool = true
    }
    
    enum Action {
        case viewInit
        case delegate(Delegate)
        case recentSearchTermButtonTapped(RecentSearchTerm)
        case deleteButtonTapped(RecentSearchTerm)
        case themeButtonTapped(SearchTheme)
        
        enum Delegate: Equatable {
            case search(String, SearchTheme)
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewInit:
                guard state.needLoad else {
                    return .none
                }
                
                if let data = UserDefaults.standard.data(forKey: "recentSearchTerms"),
                   let recentSearchTerms = try? JSONDecoder().decode([RecentSearchTerm].self, from: data) {
                    state.recentSearchTerms = recentSearchTerms
                }
                
                state.needLoad = false
                return .none
                
            case .delegate:
                return .none
                
            case let .recentSearchTermButtonTapped(recentSearchTerm):
                return .send(.delegate(.search(recentSearchTerm.searchTerm, .keyword)))
                
            case let .deleteButtonTapped(recentSearchTerm):
                if let index = state.recentSearchTerms.firstIndex(of: recentSearchTerm) {
                    state.recentSearchTerms.remove(at: index)
                }
                
                if let data = try? JSONEncoder().encode(state.recentSearchTerms) {
                    UserDefaults.standard.set(data, forKey: "recentSearchTerms")
                }
                
                return .none
                
            case let .themeButtonTapped(searchTheme):
                return .send(.delegate(.search("#\(searchTheme.text)", searchTheme)))
            }
        }
    }
}

struct SearchIdleView: View {
    @Bindable var store: StoreOf<SearchIdleFeature>
    
    init(store: StoreOf<SearchIdleFeature>) {
        self.store = store
        store.send(.viewInit)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            recentSearchTerm
            searchTheme
            Spacer()
        }
    }
    
    private var recentSearchTerm: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("최근 검색어")
                    .pretendard(.body1Bold, color: .gray90)
                    .padding(.horizontal, 20)
                Spacer()
            }
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(store.recentSearchTerms) {
                        recentSearchTermButton($0)
                    }
                }
                .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.vertical, 20)
    }
    
    @ViewBuilder
    private func recentSearchTermButton(_ recentSearchTerm: RecentSearchTerm) -> some View {
        HStack(spacing: 12) {
            Text(recentSearchTerm.searchTerm)
                .pretendard(.captionSemiBold, color: .gray70)
            Button {
                store.send(.deleteButtonTapped(recentSearchTerm))
            } label: {
                AppIcon.closeCircleFill.image(
                    width: 18,
                    height: 18,
                    appColor: .gray10
                )
                .overlay {
                    AppIcon.closeLine.image(
                        width: 12,
                        height: 12,
                        appColor: .gray50
                    )
                }
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColor.gray20.color)
        )
        .onTapGesture {
            store.send(.recentSearchTermButtonTapped(recentSearchTerm))
        }
    }
    
    private var searchTheme: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("모아보기")
                    .pretendard(.body1Bold, color: .gray90)
                    .padding(.horizontal, 20)
                Spacer()
            }
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    themeButton(.near)
                    themeButton(.neighborhood)
                    themeButton(.interest)
                }
                .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.vertical, 20)
    }
    
    @ViewBuilder
    private func themeButton(_ searchTheme: SearchTheme) -> some View {
        Button {
            store.send(.themeButtonTapped(searchTheme))
        } label: {
            HStack(spacing: 12) {
                switch searchTheme {
                case .near:
                    AppImage.mymapLine.image
                        .frame(width: 18, height: 18)
                case .neighborhood:
                    AppImage.myplaceLine.image
                        .frame(width: 18, height: 18)
                case .interest:
                    AppImage.intersetLine.image
                        .frame(width: 18, height: 18)
                default:
                    EmptyView()
                }
                Text(searchTheme.text)
                    .pretendard(.captionSemiBold, color: .gray70)
            }
            .padding(.horizontal, 12)
            .frame(height: 48)
            .background(AppColor.gray10.color)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    SearchIdleView(
        store: Store(
            initialState: SearchIdleFeature.State(
                recentSearchTerms: [
                    RecentSearchTerm(searchTerm: "스타벅스 석촌점"),
                    RecentSearchTerm(searchTerm: "브로우레시피 잠실새내점"),
                    RecentSearchTerm(searchTerm: "스타벅스 석촌역점"),
                ]
            )
        ) {
            SearchIdleFeature()
        }
    )
}
