//
//  ReviewMakingFeature.swift
//  Up
//
//  Created by Jun Young Lee on 6/19/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct ReviewMakingFeature {
    @ObservableState
    struct State: Equatable {
        var review: ReviewMaking.State?
        var reviewStates: [ReviewMaking.State] = []
        var company: ProposedCompany?
        var workLifeBalance: Double?
        var welfare: Double?
        var salary: Double?
        var companyCulture: Double?
        var management: Double?
        var jobRole: String?
        var employmentPeriod: EmploymentPeriod?
        var isLoadingIndicatorShowing = false
        var isAlertShowing = false
        var isSuccess = true
        var message = ""
        
        init(company: Company? = nil) {
            var injectedCompany: ProposedCompany?
            
            if let company {
                injectedCompany = ProposedCompany(
                    id: company.id,
                    name: company.name,
                    address: company.address.displayText,
                    totalRating: company.totalRating
                )
            }
            
            review = .information(ReviewInformationFeature.State(company: injectedCompany))
        }
        
        var currentPageText: AttributedString {
            let currentPage = reviewStates.count + 1
            let isLast = currentPage == 3
            var attributedString = AttributedString("\(currentPage)/3")
            
            attributedString.foregroundColor = isLast ? AppColor.orange40.color : AppColor.gray50.color
            attributedString.font = Typography.captionBold.font
            
            if let range = attributedString.range(of: "\(currentPage)") {
                attributedString[range].foregroundColor = AppColor.orange40.color
            }
            
            return attributedString
        }
        
        var progressBarScale: Double {
            Double(reviewStates.count + 1) / 3
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case closeButtonTapped
        case review(ReviewMaking.Action)
        case delegate(Delegate)
        case turnIsLoadingIndicatorShowing(Bool)
        case alertDoneButtonTapped
        case requestSucceeded
        case requestFailed
        
        enum Delegate: Equatable {
            case created(Review)
        }
    }
    
    @Reducer
    enum ReviewMaking {
        case information(ReviewInformationFeature)
        case rating(ReviewRatingFeature)
        case point(ReviewPointFeature)
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.companyService) var companyService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .closeButtonTapped:
                return .run { _ in await dismiss() }
                
            case let .review(.information(.delegate(.nextButtonTapped(
                company,
                jobRole,
                employmentPeriod
            )))):
                guard let currentState = state.review,
                      let company else {
                    return .none
                }
                
                state.reviewStates.append(currentState)
                state.review = .rating(ReviewRatingFeature.State(company: company))
                state.company = company
                state.jobRole = jobRole
                state.employmentPeriod = employmentPeriod
                return .none
                
            case let .review(.rating(.delegate(.previousButtonTapped(company)))):
                state.review = state.reviewStates.popLast()
                return .send(.review(.information(.setCompany(company))))
                
            case let .review(.rating(.delegate(.nextButtonTapped(
                workLifeBalance,
                welfare,
                salary,
                companyCulture,
                management
            )))):
                guard let currentState = state.review else {
                    return .none
                }
                
                state.reviewStates.append(currentState)
                state.review = .point(ReviewPointFeature.State())
                state.workLifeBalance = workLifeBalance
                state.welfare = welfare
                state.salary = salary
                state.companyCulture = companyCulture
                state.management = management
                return .none
                
            case .review(.point(.delegate(.previousButtonTapped))):
                state.review = state.reviewStates.popLast()
                return .none
                
            case let .review(.point(.delegate(.doneButtonTapped(
                advantagePoint,
                disadvantagePoint,
                managementFeedback
            )))):
                return .run { [state] send in
                    guard let id = state.company?.id,
                          let workLifeBalance = state.workLifeBalance,
                          let welfare = state.welfare,
                          let salary = state.salary,
                          let companyCulture = state.companyCulture,
                          let management = state.management,
                          let jobRole = state.jobRole,
                          let employmentPeriod = state.employmentPeriod else {
                        return
                    }
                    await send(.turnIsLoadingIndicatorShowing(true))
                    let data = try await companyService.createReview(
                        of: id,
                        workLifeBalance: workLifeBalance,
                        welfare: welfare,
                        salary: salary,
                        companyCulture: companyCulture,
                        management: management,
                        advantagePoint: advantagePoint,
                        disadvantagePoint: disadvantagePoint,
                        managementFeedback: managementFeedback,
                        jobRole: jobRole,
                        employmentPeriod: employmentPeriod.text
                    )
                    let review = data.toDomain()
                    
                    await send(.delegate(.created(review)))
                    await send(.turnIsLoadingIndicatorShowing(false))
                    await send(.requestSucceeded)
                } catch: { error, send in
                    await send(.requestFailed)
                }
                
            case .review:
                return .none
                
            case .delegate:
                return .none
                
            case let .turnIsLoadingIndicatorShowing(isShowing):
                state.isLoadingIndicatorShowing = isShowing
                return .none
                
            case .alertDoneButtonTapped:
                if state.isSuccess {
                    return .run { _ in await dismiss() }
                }
                
                return .none
                
            case .requestSucceeded:
                state.isSuccess = true
                state.message = "리뷰 작성 완료"
                state.isAlertShowing = true
                return .none
                
            case .requestFailed:
                state.isSuccess = false
                state.message = "리뷰 작성 실패"
                state.isAlertShowing = true
                return .none
            }
        }
        .ifLet(\.review, action: \.review) {
            ReviewMaking.body
        }
    }
}

extension ReviewMakingFeature.ReviewMaking.State: Equatable {}

struct ReviewMakingView: View {
    @Bindable var store: StoreOf<ReviewMakingFeature>
    
    var body: some View {
        NavigationStack {
            VStack {
                progressBar
                bodyArea
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    IconButton(
                        icon: .closeLine) {
                            store.send(.closeButtonTapped)
                        }
                }
                ToolbarItem(placement: .principal) {
                    Text("리뷰 작성")
                        .pretendard(.h2, color: .gray90)
                }
            }
        }
        .loadingIndicator(store.isLoadingIndicatorShowing)
        .appAlert(
            $store.isAlertShowing,
            isSuccess: store.isSuccess,
            message: store.message
        ) {
            store.send(.alertDoneButtonTapped)
        }
    }
    
    private var progressBar: some View {
        VStack(alignment: .trailing, spacing: 8) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .foregroundStyle(AppColor.gray10.color)
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: geometry.size.width * store.progressBarScale)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    AppColor.orange30.color,
                                    AppColor.orange40.color
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
            }
            .frame(height: 6)
            Text(store.currentPageText)
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
    
    @ViewBuilder
    private var bodyArea: some View {
        switch store.reviewStates.count {
        case 0:
            if let companyInformationStore = store.scope(state: \.review?.information, action: \.review.information) {
                ReviewInformationView(store: companyInformationStore)
            }
        case 1:
            if let ratingStore = store.scope(state: \.review?.rating, action: \.review.rating) {
                ReviewRatingView(store: ratingStore)
            }
        case 2:
            if let reviewPointStore = store.scope(state: \.review?.point, action: \.review.point) {
                ReviewPointView(store: reviewPointStore)
            }
        default:
            Spacer()
        }
    }
}

#Preview {
    ReviewMakingView(
        store: Store(
            initialState: ReviewMakingFeature.State(
                company: Company(
                    id: 3,
                    name: "육전국밥 신설동역점",
                    permissionDate: nil,
                    address: Address(
                        lotNumberAddress: "서울특별시 종로구 숭인동 1256 동보빌딩 ",
                        roadNameAddress: "서울특별시 종로구 종로 413, 동보빌딩 지상1층 (숭인동)"
                    ),
                    totalRating: 3.3,
                    isFollowed: false,
                    coordinate: Coordinate(
                        latitude: 37.575715910020854,
                        longitude: 127.02241002457775
                    )
                )
            )
        ) {
            ReviewMakingFeature()
        }
    )
}
