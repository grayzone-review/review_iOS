//
//  ReviewInformationFeature.swift
//  Up
//
//  Created by Jun Young Lee on 6/20/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct ReviewInformationFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        var company: ProposedCompany?
        var jobRole: String?
        var employmentPeriod: EmploymentPeriod?
        var isNextButtonEnabled: Bool {
            company != nil && jobRole != nil && employmentPeriod != nil
        }
        
        init(company: ProposedCompany? = nil) {
            self.company = company
        }
    }
    
    enum Action {
        case inputCompanyFieldTapped
        case setCompany(ProposedCompany)
        case inputJobRoleFieldTapped
        case selectEmploymentPeriodFieldTapped
        case nextButtonTapped
        case destination(PresentationAction<Destination.Action>)
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case nextButtonTapped(
                company: ProposedCompany?,
                jobRole: String?,
                employmentPeriod: EmploymentPeriod?
            )
        }
    }
    
    @Reducer
    enum Destination {
        case company(SelectCompanySheetFeature)
        case jobRole(TextInputSheetFeature)
        case employmentPeriod(EmploymentPeriodSheetFeature)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .inputCompanyFieldTapped:
                state.destination = .company(
                    SelectCompanySheetFeature.State(
                        selected: state.company
                    )
                )
                return .none
                
            case let .setCompany(company):
                state.company = company
                return .none
                
            case .inputJobRoleFieldTapped:
                state.destination = .jobRole(
                    TextInputSheetFeature.State(
                        title: "업무 내용",
                        placeholder: "담당하신 역할을 입력해주세요 ex) 서빙",
                        minimum: 2,
                        maximum: 10,
                        text: state.jobRole ?? ""
                    )
                )
                return .none
                
            case .selectEmploymentPeriodFieldTapped:
                state.destination = .employmentPeriod(
                    EmploymentPeriodSheetFeature.State(
                        selected: state.employmentPeriod
                    )
                )
                return .none
                
            case .nextButtonTapped:
                guard state.isNextButtonEnabled else {
                    return .none
                }
                
                return .send(.delegate(.nextButtonTapped(
                    company: state.company,
                    jobRole: state.jobRole,
                    employmentPeriod: state.employmentPeriod
                )))
                
            case let .destination(.presented(.company(.delegate(.select(company))))):
                return .send(.setCompany(company))
                
            case let .destination(.presented(.jobRole(.delegate(.save(jobRole))))):
                state.jobRole = jobRole
                return .none
                
            case let .destination(.presented(.employmentPeriod(.delegate(.select(period))))):
                state.employmentPeriod = period
                return .none
                
            case .destination:
                return .none
                
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ReviewInformationFeature.Destination.State: Equatable {}

struct ReviewInformationView: View {
    @Bindable var store: StoreOf<ReviewInformationFeature>
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    companyField
                    jobRoleField
                    employmentPeriodField
                }
                .padding(.horizontal, 20)
            }
            
            nextButton
        }
    }
    
    private var companyField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("상호명")
                .pretendard(.h3, color: .gray90)
            
            Button {
                store.send(.inputCompanyFieldTapped)
            } label: {
                HStack(spacing: 8) {
                    companyName
                    Spacer()
                    AppIcon.arrowDown.image(
                        width: 24,
                        height: 24,
                        appColor: .gray50
                    )
                }
                .padding(.vertical, 12)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(AppColor.gray20.color)
                }
            }
        }
        .padding(.vertical, 20)
        .sheet(
            item: $store.scope(state: \.destination?.company, action: \.destination.company)
        ) { sheetStore in
            SelectCompanySheetView(store: sheetStore)
        }
    }
    
    private var companyName: some View {
        Text(store.company?.name ?? "상호명을 입력해주세요")
            .pretendard(.body1Regular, color: store.company == nil ? .gray50 : .gray90)
    }
    
    private var jobRoleField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("업무 내용")
                .pretendard(.h3, color: .gray90)
            
            Button {
                store.send(.inputJobRoleFieldTapped)
            } label: {
                HStack(spacing: 8) {
                    jobRole
                    Spacer()
                }
                .padding(.vertical, 12)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(AppColor.gray20.color)
                }
            }
        }
        .padding(.vertical, 20)
        .sheet(
            item: $store.scope(state: \.destination?.jobRole, action: \.destination.jobRole)
        ) { sheetStore in
            TextInputSheetView(store: sheetStore)
        }
    }
    
    private var jobRole: some View {
        Text(store.jobRole ?? "담당하신 역할을 입력해주세요 ex) 서빙")
            .pretendard(.body1Regular, color: store.jobRole == nil ? .gray50 : .gray90)
    }
    
    private var employmentPeriodField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("근무 기간")
                .pretendard(.h3, color: .gray90)
            
            Button {
                store.send(.selectEmploymentPeriodFieldTapped)
            } label: {
                HStack(spacing: 8) {
                    employmentPeriodText
                    Spacer()
                    AppIcon.arrowDown.image(
                        width: 24,
                        height: 24,
                        appColor: .gray50
                    )
                }
                .padding(.vertical, 12)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(AppColor.gray20.color)
                }
            }
        }
        .padding(.vertical, 20)
        .sheet(
            item: $store.scope(state: \.destination?.employmentPeriod, action: \.destination.employmentPeriod)
        ) { sheetStore in
            EmploymentPeriodSheetView(store: sheetStore)
        }
    }
    
    private var employmentPeriodText: some View {
        Text(store.employmentPeriod?.text ?? "근무 기간을 선택해주세요")
            .pretendard(.body1Regular, color: store.employmentPeriod == nil ? .gray50 : .gray90)
    }
    
    private var nextButton: some View {
        AppButton(
            style: .fill,
            size: .large,
            text: "다음",
            isEnabled: store.isNextButtonEnabled
        ) {
            store.send(.nextButtonTapped)
        }
        .padding(20)
    }
}

#Preview {
    ReviewInformationView(
        store: Store(
            initialState: ReviewInformationFeature.State(
                //                company: ProposedCompany(
                //                    id: 1,
                //                    name: "스타벅스 석촌역점",
                //                    address: "서울특별시 송파구 백제고분로 358 1층",
                //                    totalRating: 0
                //                )
            )
        ) {
            ReviewInformationFeature()
        }
    )
}
