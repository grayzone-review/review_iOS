//
//  SearchArea.swift
//  Up
//
//  Created by Wonbi on 7/1/25.
//

import SwiftUI


import ComposableArchitecture

@Reducer
struct SearchAreaFeature {
    @ObservableState
    struct State: Equatable {
        /// 사용자에게 입력받은 검색어
        var searchText: String = ""
        /// 비동기 로직이 수행중인지 아닌지 나타내는 값
        var isLoading: Bool = false
        var isFocused: Bool = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case viewInit
        case handleError(Error)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .viewInit:
                return .none
            case let .handleError(_):
                // TODO: - 에러 핸들링
                return .none
            }
        }
    }
}

struct SearchAreaView: View {
    @Environment(\.dismiss) var dismiss
    
    @Bindable var store: StoreOf<SearchAreaFeature>
    
    init(store: StoreOf<SearchAreaFeature>) {
        self.store = store
        store.send(.viewInit)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                inputAreaNameView
                
                Rectangle()
                    .fill(AppColor.gray10.color)
                    .frame(height: 8)
                
                searchMyAreaView
                
                areaNameCell
                areaNameSelectedCell
                areaNameCell
            }
        }
        .toolbar(.hidden)
        .navigationBarBackButtonHidden(true)
    }
    
    
    var inputAreaNameView: some View {
        HStack(spacing: 0) {
            AppIcon.arrowLeft
                .image(width: 24, height: 24)
                .padding(10)
                .padding(.trailing, 4)
            
            UPTextField(
                style: .fill,
                text: $store.searchText,
                isFocused: $store.isFocused,
                placeholder: "동명 (읍, 면)으로 검색 (ex. 서초동)",
                rightComponent: .clear(),
                onFocusedChange: { old, new in
                    
                },
                onTextChange: { old, new in
                    
                }
            )
            .padding(.trailing, 16)
            
            Button {
                
            } label: {
                Text("취소")
                    .pretendard(.body1Regular, color: .gray90)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
    }
    
    var searchMyAreaView: some View {
        AppButton(
            icon: .mapPinFill,
            style: .fill,
            size: .regular,
            mode: .fill,
            text: "내 위치 찾기"
        ) {
            
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
    }
    
    var areaNameCell: some View {
        HStack(spacing: 0) {
            Text(" • 서울특별시 서초구 서초동")
                .pretendard(.body1Regular, color: .gray90)
            
            Spacer(minLength: 0)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(AppColor.white.color)
    }
    
    var areaNameSelectedCell: some View {
        HStack(spacing: 0) {
            Text(" • 서울특별시 서초구 서초동")
                .pretendard(.body1Bold, color: .orange40)
            
            Spacer(minLength: 0)
            
            AppIcon.checkCircleFill.image(width: 24, height: 24)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(AppColor.gray10.color)
    }
}

#Preview {
    NavigationStack {
        SearchAreaView(
            store: Store(
                initialState: SearchAreaFeature.State(),
                reducer: {
                    SearchAreaFeature()
                }
            )
        )
    }
}
