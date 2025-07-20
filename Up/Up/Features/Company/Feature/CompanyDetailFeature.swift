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
        var company: Company?
        var reviews: [Review] = []
        var hasNextPage: Bool = true
        var isLoading: Bool = false
        
        var loadPoint: Review? {
            guard reviews.count > 3 else {
                return nil
            }
            
            return reviews[reviews.count - 3]
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case viewInit
        case saveCompany
        case companyInformationFetched(Company)
        case loadReivews
        case companyReviewsFetched(ReviewsBody)
        case backButtonTapped
        case followButtonTapped
        case follow
        case makeReviewButtonTapped
        case destination(PresentationAction<Destination.Action>)
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
    @Dependency(\.companyService) var companyService
    @Dependency(\.reviewService) var reviewService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return.none
                
            case .viewInit :
                guard state.company == nil else {
                    return .none
                }
                
                state.isLoading = true
                
                return .run { [id = state.companyID] send in
                    let data = try await companyService.fetchCompany(of: id)
                    let company = data.toDomain()
                    
                    await send(.companyInformationFetched(company))
                    await send(.saveCompany)
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
                
                if let data = UserDefaults.standard.data(forKey: "savedCompanies"),
                   let recentSavedCompanies = try? JSONDecoder().decode([SavedCompany].self, from: data) {
                    savedCompanies = recentSavedCompanies
                }
                
                if let index = savedCompanies.firstIndex(where: { $0.id == company.id }) {
                    savedCompanies.remove(at: index)
                }
                
                savedCompanies.insert(savedCompany, at: 0)
                
                if let data = try? JSONEncoder().encode(savedCompanies) {
                    UserDefaults.standard.set(data, forKey: "savedCompanies")
                }
                
                return .none
                
            case let .companyInformationFetched(company):
                state.company = company
                state.isLoading = false
                return .send(.loadReivews)
                
            case .loadReivews:
                guard state.isLoading == false,
                      state.hasNextPage else {
                    return .none
                }
                
                state.isLoading = true
                
                return .run { [companyID = state.companyID, page = state.reviews.count / 10] send in
                    let data = try await companyService.fetchReviews(of: companyID, page: page)
                    await send(.companyReviewsFetched(data))
                }
                
            case let .companyReviewsFetched(body):
                state.reviews += body.reviews.map { $0.toDomain() }
                state.hasNextPage = body.hasNext
                state.isLoading = false
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
                }
                
            case .makeReviewButtonTapped:
                state.destination = .review(ReviewMakingFeature.State(company: state.company))
                return .none
                
            case let .destination(.presented(.review(.delegate(.created(review))))):
                state.reviews.insert(review, at: 0)
                return .none
                
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension CompanyDetailFeature.Destination.State: Equatable {}

struct CompanyDetailView: View {
    @Bindable var store: StoreOf<CompanyDetailFeature>
    
    init(store: StoreOf<CompanyDetailFeature>) {
        self.store = store
        store.send(.viewInit)
    }
    
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
    }
    
    private var information: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(store.company?.name ?? "")
                    .pretendard(.h3, color: .gray90)
                
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
                    .pretendard(.h1, color: .gray90)
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
            style: .fill,
            text: "팔로우"
        ) {
            store.send(.followButtonTapped)
        }
    }
    
    var makeReviewButton: some View {
        AppButton(
            icon: .penFill,
            style: .stroke,
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
        if store.reviews.isEmpty {
            empty
        } else {
            reviewList
        }
    }
    
    private var empty: some View {
        VStack(alignment: .center, spacing: 12) {
            AppIcon.reviewFill.image(
                width: 48,
                height: 48,
                appColor: .gray30
            )
            Text("아직 등록된 리뷰가 없습니다.")
                .pretendard(.body1Regular, color: .gray50)
        }
        .frame(height: 290)
    }
    
    private var reviewList: some View {
        LazyVStack(spacing: 0) {
            ForEach($store.reviews) { $review in
                ReviewCardView(
                    store: Store(
                        initialState: ReviewCardFeature.State(
                            review: review
                        )
                    ) {
                        ReviewCardFeature()
                    },
                    review: $review
                )
                .onAppear {
                    if store.loadPoint == review {
                        store.send(.loadReivews)
                    }
                }
                divider
            }
        }
    }
    
    private var divider: some View {
        Divider()
            .background(AppColor.gray20.color)
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
