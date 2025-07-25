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
        var isAlertShowing = false
        var error: FailResponse?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case termChanged
        case fetchProposedCompanies
        case setProposedCompanies([ProposedCompany])
        case selectCompany(ProposedCompany)
        case delegate(Delegate)
        case handleError(Error)
        
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
                } catch: { error, send in
                    await send(.handleError(error))
                }
                
            case let .setProposedCompanies(companies):
                state.proposedCompanies = companies
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
                
            case let .handleError(error):
                if let failResponse = error as? FailResponse {
                    state.error = failResponse
                    state.isAlertShowing = true
                    return .none
                } else {
                    print("❌ error: \(error)")
                    return .none
                }
            }
        }
    }
}

struct SelectCompanySheetView: View {
    @Bindable var store: StoreOf<SelectCompanySheetFeature>
    @State var isFocused = true
    
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
        .appAlert($store.isAlertShowing, isSuccess: false, message: store.error?.message ?? "")
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
        UPTextField(
            text: $store.searchTerm,
            isFocused: $isFocused,
            placeholder: "상호명으로 검색하기",
            leftComponent: .icon(appIcon: .searchLine, size: 24, color: .gray90),
            rightComponent: .clear(),
            onTextChange: { _, _ in store.send(.termChanged) }
        )
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
    private var searchedCompany: some View {
        if store.proposedCompanies.isEmpty {
            emptyProposed
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
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
            AppIcon.searchLine.image(
                width: 48,
                height: 48,
                appColor: .gray30
            )
            Text("검색 결과를 찾을 수 없습니다.")
                .pretendard(.body1Regular, color: .gray50)
            Spacer()
        }
    }
    
    @ViewBuilder
    private func proposedCompanyButton(_ company: ProposedCompany) -> some View {
        VStack(spacing: 0) {
            Button {
                store.send(.selectCompany(company))
            } label: {
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(company.name)
                            .pretendard(.body1Bold, color: .gray90)
                        Text(company.address)
                            .pretendard(.captionRegular, color: .gray50)
                    }
                    .multilineTextAlignment(.leading)
                    Spacer()
                    if store.selected?.id == company.id {
                        AppIcon.checkCircleFill.image
                            .frame(width: 24, height: 24)
                    }
                }
                .padding(20)
                .background(store.selected?.id == company.id ? AppColor.gray10.color : nil)
            }
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
