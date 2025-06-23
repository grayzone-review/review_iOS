//
//  EmploymentPeriodSheetFeature.swift
//  Up
//
//  Created by Jun Young Lee on 6/20/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct EmploymentPeriodSheetFeature {
    @ObservableState
    struct State: Equatable {
        var selected: EmploymentPeriod?
    }
    
    enum Action {
        case select(EmploymentPeriod)
        case closeButtonTapped
        case close
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case select(EmploymentPeriod?)
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
            case let .select(period):
                state.selected = period
                return .send(.close)
                    .debounce(
                        id: CancelID.debounce,
                        for: 0.3,
                        scheduler: mainQueue
                    )
                
            case .closeButtonTapped:
                return .send(.close)
                
            case .close:
                return .run { [period = state.selected] send in
                    await send(.delegate(.select(period)))
                    await dismiss()
                }
            case .delegate:
                return .none
            }
        }
    }
}

struct EmploymentPeriodSheetView: View {
    @Bindable var store: StoreOf<EmploymentPeriodSheetFeature>
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            handle
            title
            periods
            closeButton
        }
        .presentationDetents([.height(500)])
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
            Text("근무 기간")
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
    
    private var periods: some View {
        ForEach(EmploymentPeriod.allCases) { period in
            periodButton(period)
        }
    }
    
    private func periodButton(_ period: EmploymentPeriod) -> some View {
        let isSelected = store.selected == period
        
        return Button {
            store.send(.select(period))
        } label: {
            HStack {
                Text(period.text)
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
    EmploymentPeriodSheetView(
        store: Store(
            initialState: EmploymentPeriodSheetFeature.State()
        ) {
            EmploymentPeriodSheetFeature()
        }
    )
}
