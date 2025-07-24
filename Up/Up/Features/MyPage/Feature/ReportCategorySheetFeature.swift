//
//  ReportCategorySheetFeature.swift
//  Up
//
//  Created by Jun Young Lee on 7/21/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct ReportCategorySheetFeature {
    @ObservableState
    struct State: Equatable {
        var selected: ReportCategory?
    }
    
    enum Action {
        case select(ReportCategory)
        case closeButtonTapped
        case close
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case select(ReportCategory?)
        }
    }
    
    enum CancelID: Hashable {
        case debounce
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.mainQueue) var mainQueue
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .select(category):
                state.selected = category
                return .send(.close)
                    .debounce(
                        id: CancelID.debounce,
                        for: 0.3,
                        scheduler: mainQueue
                    )
                
            case .closeButtonTapped:
                return .send(.close)
                
            case .close:
                return .run { [category = state.selected] send in
                    await send(.delegate(.select(category)))
                    await dismiss()
                }
            case .delegate:
                return .none
            }
        }
    }
}

struct ReportCategorySheetView: View {
    let store: StoreOf<ReportCategorySheetFeature>
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            handle
            title
            categories
            closeButton
        }
        .presentationDetents([.height(426)])
        .presentationCornerRadius(24)
        .presentationDragIndicator(.hidden)
    }
    
    private var handle: some View {
        VStack {
            RoundedRectangle(cornerRadius: 2)
                .foregroundStyle(AppColor.dragIndicator.color)
                .frame(width: 36, height: 4)
        }
        .frame(height: 24)
    }
    
    private var title: some View {
        HStack {
            Spacer()
            Text("신고 사유")
                .pretendard(.body1Bold, color: .gray90)
            Spacer()
        }
        .padding(
            EdgeInsets(
                top: 8,
                leading: 20,
                bottom: 8,
                trailing: 20
            )
        )
    }
    
    private var categories: some View {
        ForEach(ReportCategory.allCases) { category in
            categoryButton(category)
        }
    }
    
    private func categoryButton(_ category: ReportCategory) -> some View {
        let isSelected = store.selected == category
        
        return Button {
            store.send(.select(category))
        } label: {
            HStack {
                Text(category.text)
                Spacer()
                if isSelected {
                    AppIcon.checkLine.image
                        .frame(width: 20, height: 20)
                }
            }
            .pretendard(
                isSelected ? .body1Bold : .body1Regular,
                color: isSelected ? .orange40 : .gray90
            )
            .padding(20)
            .frame(height: 64)
            .background(isSelected ? AppColor.gray10.color : nil)
        }
    }
    
    private var closeButton: some View {
        Button {
            store.send(.closeButtonTapped)
        } label: {
            HStack {
                Text("닫기")
                    .pretendard(.body1Regular, color: .gray90)
            }
            .frame(height: 48)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ReportCategorySheetView(
        store: Store(
            initialState: ReportCategorySheetFeature.State()
        ) {
            ReportCategorySheetFeature()
        }
    )
}
