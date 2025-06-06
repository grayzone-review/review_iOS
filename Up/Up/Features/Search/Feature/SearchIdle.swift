//
//  SearchIdle.swift
//  Up
//
//  Created by Jun Young Lee on 6/6/25.
//

import ComposableArchitecture
import SwiftUI
import SwiftData

@Reducer
struct SearchIdleFeature {
    @ObservableState
    struct State: Equatable {
        var recentSearchTerms: [RecentSearchTerm]
    }
    
    enum Action {
        case delegate(Delegate)
        case recentSearchTermButtonTapped(RecentSearchTerm)
        case deleteButtonTapped(RecentSearchTerm, ModelContext)
        case themeButtonTapped(SearchTheme)
        
        enum Delegate: Equatable {
            case updateRecentSearchTerms([RecentSearchTerm])
            case search(String, SearchTheme)
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .delegate:
                return .none
                
            case let .recentSearchTermButtonTapped(recentSearchTerm):
                return .send(.delegate(.search(recentSearchTerm.searchTerm, .keyword)))
                
            case let .deleteButtonTapped(recentSearchTerm, modelContext):
                if let index = state.recentSearchTerms.firstIndex(of: recentSearchTerm) {
                    state.recentSearchTerms.remove(at: index)
                }
                modelContext.delete(recentSearchTerm)
                try? modelContext.save()
                return .send(.delegate(.updateRecentSearchTerms(state.recentSearchTerms)))
                
            case let .themeButtonTapped(searchTheme):
                return .send(.delegate(.search("#\(searchTheme.text)", searchTheme)))
            }
        }
    }
}

struct SearchIdleView: View {
    @Bindable var store: StoreOf<SearchIdleFeature>
    @Environment(\.modelContext) var modelContext
    
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
                store.send(.deleteButtonTapped(recentSearchTerm, modelContext))
            } label: {
                AppIcon.closeFill.image
                    .foregroundStyle(AppColor.gray10.color)
                    .frame(width: 18, height: 18)
                    .overlay {
                        AppIcon.closeLine.image
                            .foregroundStyle(AppColor.gray50.color)
                            .frame(width: 12, height: 12)
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
    
    private func themeButton(_ searchTheme: SearchTheme) -> some View {
        Button {
            store.send(.themeButtonTapped(searchTheme))
        } label: {
            HStack(spacing: 12) {
                AppImage.myplaceLine.image
                    .frame(width: 18, height: 18)
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
