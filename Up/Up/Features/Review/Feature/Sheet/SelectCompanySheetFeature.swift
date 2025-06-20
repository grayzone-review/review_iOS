//
//  SelectCompanySheetFeature.swift
//  Up
//
//  Created by Jun Young Lee on 6/20/25.
//

import ComposableArchitecture

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
