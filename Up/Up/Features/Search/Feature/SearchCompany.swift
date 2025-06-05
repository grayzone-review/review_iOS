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
        var searchState: SearchState = .idle
        var searchTerm: String = ""
        var isFocused: Bool = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case backButtonTapped
        case textFieldFocused
        case clearButtonTapped
        case cancelButtonTapped
        case enterButtonTapped
        case termChanged
        case fetchRelatedCompanies
    }
    
    enum CancelID { case debounce }
    
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
                state.searchState = .focused
                return .none
                
            case .clearButtonTapped:
                state.searchTerm = ""
                return .run { send in
                    await send(.textFieldFocused)
                }
                
            case .cancelButtonTapped:
                state.searchTerm = ""
                state.searchState = .idle
                state.isFocused = false
                return .none
                
            case .enterButtonTapped:
                state.searchState = .submitted
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
            }
        }
    }
}

struct SearchCompanyView: View {
    @Bindable var store: StoreOf<SearchCompanyFeature>
    @FocusState var isFocused: Bool
    
    var body: some View {
        ScrollView {
            enterSearchTermArea
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
