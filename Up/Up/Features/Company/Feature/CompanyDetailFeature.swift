//
//  CompanyDetailFeature.swift
//  Up
//
//  Created by Jun Young Lee on 6/1/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct CompanyDetailFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        let companyID: Int
        var review: CompanyReviewFeature.State?
        var company: Company?
        var isAlertShowing = false
        var error: FailResponse?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case review(CompanyReviewFeature.Action)
        case viewAppear
        case saveCompany
        case companyInformationFetched(Company)
        case backButtonTapped
        case followButtonTapped
        case follow
        case makeReviewButtonTapped
        case destination(PresentationAction<Destination.Action>)
        case handleError(Error)
    }
    
    @Reducer
    enum Destination {
        case review(ReviewMakingFeature)
    }
    
    enum CancelID: Hashable {
        case follow
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.userDefaultsService) var userDefaultsService
    @Dependency(\.companyService) var companyService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return.none
                
            case let .review(.delegate(.alert(error))):
                return .send(.handleError(error))
                
            case .review:
                return .none
                
            case .viewAppear :
                guard state.company == nil else {
                    return .none
                }
                
                return .run { [id = state.companyID] send in
                    let data = try await companyService.fetchCompany(of: id)
                    let company = data.toDomain()
                    
                    await send(.companyInformationFetched(company))
                    await send(.saveCompany)
                } catch: { error, send in
                    await send(.handleError(error))
                }
                
            case .saveCompany:
                guard let company = state.company else {
                    return .none
                }
                
                let savedCompany = SavedCompany(
                    id: company.id,
                    name: company.name,
                    address: company.address.displayText
                )
                var savedCompanies = [SavedCompany]()
                
                if let recentSavedCompanies = try? userDefaultsService.fetch(key: "savedCompanies", type: [SavedCompany].self) {
                    savedCompanies = recentSavedCompanies
                }
                
                if let index = savedCompanies.firstIndex(where: { $0.id == company.id }) {
                    savedCompanies.remove(at: index)
                }
                
                savedCompanies.insert(savedCompany, at: 0)
                try? userDefaultsService.save(key: .savedCompanies, value: savedCompanies)
                
                return .none
                
            case let .companyInformationFetched(company):
                state.company = company
                state.review = CompanyReviewFeature.State(companyID: state.companyID)
                return .none
                
            case .backButtonTapped:
                return .run { _ in await dismiss() }
                
            case .followButtonTapped:
                state.company?.isFollowed.toggle()
                return .send(.follow)
                    .debounce(
                        id: CancelID.follow,
                        for: 1,
                        scheduler: mainQueue
                    )
                
            case .follow:
                return .run { [company = state.company] _ in
                    guard let company else {
                        return
                    }
                    
                    if company.isFollowed {
                        try await companyService.createCompanyFollowing(of: company.id)
                    } else {
                        try await companyService.deleteCompanyFollowing(of: company.id)
                    }
                } catch: { error, send in
                    await send(.handleError(error))
                }
                
            case .makeReviewButtonTapped:
                state.destination = .review(ReviewMakingFeature.State(company: state.company))
                return .none
                
            case let .destination(.presented(.review(.delegate(.created(review))))):
                return .send(.review(.reviewWritten(review)))
                
            case .destination:
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
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.review, action: \.review) {
            CompanyReviewFeature()
        }
    }
}

extension CompanyDetailFeature.Destination.State: Equatable {}

struct CompanyDetailView: View {
    @Bindable var store: StoreOf<CompanyDetailFeature>
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                information
                interaction
                map
            }
            .padding(EdgeInsets(top: 16, leading: 20, bottom: 20, trailing: 20))
            
            separator
            review
        }
        .onAppear {
            store.send(.viewAppear)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                IconButton(
                    icon: .arrowLeft) {
                        store.send(.backButtonTapped)
                    }
            }
            ToolbarItem(placement: .principal) {
                Text(store.company?.name ?? "")
                    .pretendard(.h2, color: .gray90)
            }
        }
        .appAlert($store.isAlertShowing, isSuccess: false, message: store.error?.message ?? "")
    }
    
    private var information: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(store.company?.name ?? "")
                    .pretendard(.h3Bold, color: .gray90)
                
                Text(store.company?.address.displayText ?? "")
                    .pretendard(.captionRegular, color: .gray50)
            }
            HStack(spacing: 4) {
                AppIcon.starFill.image(
                    width: 24,
                    height: 24,
                    appColor: .seYellow40
                )
                Text(String(store.company?.totalRating.rounded(to: 1) ?? 0))
                    .pretendard(.h1Bold, color: .gray90)
            }
        }
    }
    
    private var interaction: some View {
        HStack(spacing: 12) {
            followButton
            makeReviewButton
        }
    }
    
    @ViewBuilder
    var followButton: some View {
        let isFollowed = store.company?.isFollowed == true
        
        AppButton(
            icon: isFollowed ? .followingFill : .followLine,
            style: isFollowed ? .fill : .stroke,
            text: isFollowed ? "팔로잉" : "팔로우"
        ) {
            store.send(.followButtonTapped)
        }
    }
    
    var makeReviewButton: some View {
        AppButton(
            icon: .penFill,
            style: .fill,
            text: "리뷰 작성"
        ) {
            store.send(.makeReviewButtonTapped)
        }
        .fullScreenCover(
            item: $store.scope(state: \.destination?.review, action: \.destination.review)
        ) { reviewStore in
            ReviewMakingView(store: reviewStore)
        }
    }
    
    var map: some View {
        Group {
            if let company = store.company {
                KakaoMapCardView(coordinate: company.coordinate)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .frame(height: 188)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColor.gray20.color)
        )
    }
    
    private var separator: some View {
        Rectangle()
            .foregroundStyle(AppColor.gray20.color)
            .frame(height: 8)
    }
    
    @ViewBuilder
    private var review: some View {
        if let store = store.scope(state: \.review, action: \.review) {
            CompanyReviewView(store: store)
        }
    }
}

#Preview {
    NavigationStack {
        CompanyDetailView(
            store: Store(
                initialState: CompanyDetailFeature.State(
                    companyID: 1
                )
            ) {
                CompanyDetailFeature()
            }
        )
    }
}
