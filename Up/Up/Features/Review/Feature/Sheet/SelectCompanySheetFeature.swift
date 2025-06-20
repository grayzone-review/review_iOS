//
//  SelectCompanySheetFeature.swift
//  Up
//
//  Created by Jun Young Lee on 6/20/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct SelectCompanySheetFeature {
    @ObservableState
    struct State: Equatable {
        var selected: ProposedCompany?
        var searchTerm: String = ""
        var proposedCompanies: [ProposedCompany] = []
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case termChanged
        case fetchProposedCompanies
        case setProposedCompanies([ProposedCompany])
        case clearButtonTapped
        case selectCompany(ProposedCompany)
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case select(ProposedCompany)
        }
    }
    
    enum CancelID: Hashable {
        case debounce(Debounce)
        
        enum Debounce {
            case fetch
            case select
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.searchService) var searchService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .termChanged:
                return .send(.fetchProposedCompanies)
                    .debounce(
                        id: CancelID.debounce(.fetch),
                        for: 0.5,
                        scheduler: mainQueue
                    )
                
            case .fetchProposedCompanies:
                return .run { [state] send in
                    let data = try await searchService.fetchProposedCompanies(
                        keyword: state.searchTerm,
                        latitude: 37.5665, // 추후 위치 권한 설정후 위,경도 입력으로 변경. 혹은 keyword만 받도록 수정.
                        longitude: 126.9780
                    )
                    let companies = data.companies.map { $0.toDomain() }
                    await send(.setProposedCompanies(companies))
                }
                
            case let .setProposedCompanies(companies):
                state.proposedCompanies = companies
                return .none
                
            case .clearButtonTapped:
                state.searchTerm = ""
                return .none
                
            case let .selectCompany(company):
                state.selected = company
                return .run { send in
                    await send(.delegate(.select(company)))
                    await dismiss()
                }
                .debounce(
                    id: CancelID.debounce(.select),
                    for: 0.3,
                    scheduler: mainQueue
                )
                
            case .delegate:
                return .none
            }
        }
    }
}

struct SelectCompanySheetView: View {
    @Bindable var store: StoreOf<SelectCompanySheetFeature>
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            handle
            enterSearchTermArea
            searchedCompany
        }
        .onAppear {
            isFocused = true
        }
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
    
    private var enterSearchTermArea: some View {
        HStack(spacing: 8) {
            searchIcon
            textField
            clearButton
        }
        .padding(16)
        .frame(height: 52)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(isFocused ? AppColor.gray90.color : AppColor.gray20.color)
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
        .lineLimit(1)
        .pretendard(.body1Regular, color: .gray90)
        .onChange(of: store.searchTerm) { _, _ in
            store.send(.termChanged)
        }
    }
    
    private var clearButton: some View {
        Button {
            store.send(.clearButtonTapped)
        } label: {
            AppIcon.closeCircleFill.image
                .foregroundStyle(AppColor.gray10.color)
                .frame(width: 24, height: 24)
                .overlay {
                    AppIcon.closeLine.image
                        .foregroundStyle(AppColor.gray50.color)
                        .frame(width: 16, height: 16)
                }
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
                        proposedCompanyButton(company)
                    }
                }
            }
        }
    }
    
    private var emptyProposed: some View {
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
    
    @ViewBuilder
    private func proposedCompanyButton(_ company: ProposedCompany) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(company.name)
                        .pretendard(.body1Bold, color: .gray90)
                    Text(company.address)
                        .pretendard(.captionRegular, color: .gray50)
                }
                Spacer()
                if store.selected == company {
                    AppIcon.checkCircleFill.image
                        .foregroundStyle(AppColor.orange40.color)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(20)
            .background(store.selected == company ? AppColor.gray10.color : nil)
            Divider()
        }
    }
}

#Preview {
    SelectCompanySheetView(
        store: Store(
            initialState: SelectCompanySheetFeature.State()
        ) {
            SelectCompanySheetFeature()
        }
    )
}
