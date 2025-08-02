//
//  HomeFeature.swift
//  Up
//
//  Created by Jun Young Lee on 6/27/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct HomeFeature {
    @ObservableState
    struct State: Equatable {
        @Shared(.user) var user
        var isFirst: Bool = true
        var currentLocation: Location = .default
        var popularReviews = [HomeReview]()
        var mainRegionReviews = [HomeReview]()
        var interestedRegionReviews = [HomeReview]()
        
        var userName: String {
            user?.nickname ?? "사용자"
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case viewAppear
        case requestCurrentLocation
        case fetchDefaultLocation
        case currentLocationFetched(Location)
        case fetchPopularReviews
        case popularReviewsFetched([HomeReview])
        case fetchMainRegionReviews
        case mainRegionReviewsFetched([HomeReview])
        case fetchInterestedRegionReviews
        case interestedRegionReviewsFetched([HomeReview])
        case delegate(Delegate)
        case handleLocationError(Error)
        
        enum Delegate {
            case alert(Error)
        }
    }
    
    @Dependency(\.homeService) var homeService
    @Dependency(\.userDefaultsService) var userDefaultsService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return.none
                
            case .viewAppear:
                return .run { send in
                    await send(.requestCurrentLocation)
                    await send(.fetchPopularReviews)
                    await send(.fetchMainRegionReviews)
                    await send(.fetchInterestedRegionReviews)
                }
                
            case .requestCurrentLocation:
                return .run { send in
                    let location = try await LocationService.shared.requestCurrentLocation()
                    
                    let current = location.toDomain()
                    await send(.currentLocationFetched(current))
                } catch: { error, send in
                    await send(.handleLocationError(error))
                }
            case let .currentLocationFetched(location):
                try? userDefaultsService.save(key: .latitude, value: location.lat)
                try? userDefaultsService.save(key: .longitude, value: location.lng)
                
                state.currentLocation = location
                
                return .none
            case .fetchDefaultLocation:
                if let lat = try? userDefaultsService.fetch(key: .latitude, type: Double.self),
                   let lng = try? userDefaultsService.fetch(key: .longitude, type: Double.self) {
                    state.currentLocation = Location(lat: lat, lng: lng)
                }
                
                return .none
                
            case let .handleLocationError(error):
                    if state.isFirst {
                        state.isFirst = false
                        return .send(.delegate(.alert(error)))
                    } else {
                        return .send(.fetchDefaultLocation)
                    }
                
            case .fetchPopularReviews:
                guard state.popularReviews.isEmpty else {
                    return .none
                }
                let location = state.currentLocation
                return .run { send in
                    let data = try await homeService.fetchPopularReviews(
                        latitude: location.lat,
                        longitude: location.lng,
                        page: 0
                    )
                    let reviews = data.reviews.map { $0.toDomain() }
                    
                    await send(.popularReviewsFetched(reviews))
                } catch: { error, send in
                    await send(.popularReviewsFetched([]))
                }
                
            case let .popularReviewsFetched(reviews):
                state.popularReviews = reviews
                return .none
                
            case .fetchMainRegionReviews:
                guard state.mainRegionReviews.isEmpty else {
                    return .none
                }
                let location = state.currentLocation
                
                return .run { send in
                    let data = try await homeService.fetchMainRegionReviews(
                        latitude: location.lat,
                        longitude: location.lng,
                        page: 0
                    )
                    let reviews = data.reviews.map { $0.toDomain() }
                    
                    await send(.mainRegionReviewsFetched(reviews))
                } catch: { error, send in
                    await send(.mainRegionReviewsFetched([]))
                }
                
            case let .mainRegionReviewsFetched(reviews):
                state.mainRegionReviews = reviews
                return .none
                
            case .fetchInterestedRegionReviews:
                guard state.interestedRegionReviews.isEmpty else {
                    return .none
                }
                let location = state.currentLocation
                
                return .run { send in
                    let data = try await homeService.fetchInterestedRegionReviews(
                        latitude: location.lat,
                        longitude: location.lng,
                        page: 0
                    )
                    let reviews = data.reviews.map { $0.toDomain() }
                    
                    await send(.interestedRegionReviewsFetched(reviews))
                } catch: { error, send in
                    await send(.interestedRegionReviewsFetched([]))
                }
                
            case let .interestedRegionReviewsFetched(reviews):
                state.interestedRegionReviews = reviews
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}

struct HomeView: View {
    enum ScrollPosition: Int, Identifiable {
        case top
        
        var id: Int {
            rawValue
        }
    }
    
    @Bindable var store: StoreOf<HomeFeature>
    @State private var scrollPosition: ScrollPosition?
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView {
                VStack(spacing: 0) {
                    searchButton
                    banners
                    selectInterestButton
                    seperator
                    popularReviews
                    mainRegionReviews
                    interestedRegionReviews
                }
                .padding(.bottom, 60)
                .id(ScrollPosition.top)
            }
            .scrollPosition(id: $scrollPosition, anchor: .top)
            .scrollIndicators(.hidden)
            .padding(.bottom, 0.5) // 탭바 아래로 반투명 비쳐보임 방지
        }
        .onAppear {
            store.send(.viewAppear)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private var navigationBar: some View {
        HStack(spacing: 8) {
            iconButton
            Spacer()
            nicknameButton
        }
        .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
    }
    
    private var iconButton: some View {
        Button {
            scrollPosition = .top
        } label: {
            Text("Up")
                .pretendard(.logo, color: .orange40)
        }
    }
    
    private var nicknameButton: some View {
        NavigationLink(
            state: UpFeature.MainPath.State.activity(
                MyActivityFeature.State(selectedTab: .activity)
            )
        ) {
            HStack(spacing: 4) {
                Text(store.userName + "님")
                    .pretendard(.body1Bold, color: .orange40)
                AppIcon.arrowRight.image(width: 18, height: 18, appColor: .orange40)
            }
        }
    }
    
    private var searchButton: some View {
        NavigationLink(
            state: UpFeature.MainPath.State.search(
                SearchCompanyFeature.State()
            )
        ) {
            HStack(spacing: 10) {
                AppIcon.searchLine.image(width: 24, height: 24, appColor: .gray90)
                Text("재직자들의 리뷰 찾아보기")
                    .pretendard(.body1Regular, color: .gray50)
                Spacer()
            }
            .padding(16)
            .frame(height: 52)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColor.gray20.color)
            )
        }
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
    }
    
    private var banners: some View {
        HStack(spacing: 12) {
            encourageReviewBanner
            VStack(spacing: 12) {
                myReviewsBanner
                followingListBanner
            }
        }
        .padding(20)
    }
    
    private var encourageReviewBanner: some View {
        NavigationLink(
            state: UpFeature.MainPath.State.search(
                SearchCompanyFeature.State()
            )
        ) {
            ZStack(alignment: .bottom) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("우리 동네 리뷰가\n궁금하다면?")
                            .pretendard(.body1Bold, color: .white)
                            .multilineTextAlignment(.leading)
                        HStack(spacing: 4) {
                            Text("지금 리뷰 검색하러 가기")
                                .pretendard(.captionSemiBold, color: .white)
                            AppIcon.arrowRight.image(width: 14, height: 14, appColor: .white)
                        }
                        Spacer()
                    }
                    .padding([.top, .leading], 16)
                    
                    Spacer()
                }
                
                AppImage.mapPin.image
                    .aspectRatio(165/84, contentMode: .fit)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 188)
            .background(AppColor.orange40.color)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private var myReviewsBanner: some View {
        NavigationLink(
            state: UpFeature.MainPath.State.activity(
                MyActivityFeature.State(selectedTab: .review)
            )
        ) {
            ZStack(alignment: .bottomTrailing) {
                HStack {
                    VStack(spacing: 8) {
                        Text("내가\n작성한 리뷰")
                            .pretendard(.body1Bold, color: .gray80)
                            .multilineTextAlignment(.leading)
                            .padding([.leading, .top], 16)
                        Spacer()
                    }
                    Spacer()
                }
                AppIcon.chatSecondFill.image(
                    width: 32,
                    height: 32,
                    appColor: .orange40
                )
                .padding([.bottom, .trailing], 16)
            }
            .frame(maxWidth: .infinity)
            .background(AppColor.gray10.color)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColor.gray20.color)
            }
        }
    }
    
    private var followingListBanner: some View {
        NavigationLink(
            state: UpFeature.MainPath.State.activity(
                MyActivityFeature.State(selectedTab: .following)
            )
        ) {
            ZStack(alignment: .bottomTrailing) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("팔로우한\n업체")
                            .pretendard(.body1Bold, color: .gray80)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding([.top, .leading], 16)
                    
                    Spacer()
                }
                AppIcon.followingFill.image(
                    width: 32,
                    height: 32,
                    appColor: .orange40
                )
                .padding([.bottom, .trailing], 16)
            }
            .frame(maxWidth: .infinity)
            .background(AppColor.gray10.color)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColor.gray20.color)
            }
        }
    }
    
    @ViewBuilder
    private var selectInterestButton: some View {
        if store.user?.interestedRegions.isEmpty != false { // 관심 동네가 없을 경우에만 노출
            HStack { // 관련 화면 작업 후 NavigationLink로 래핑
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 4) {
                        Text("관심 동네 선택하러 가기 ")
                            .pretendard(.body1Bold, color: .gray90)
                        AppIcon.arrowRight.image(width: 20, height: 20, appColor: .gray90)
                    }
                    Text("관심 동네 선택하고 리뷰 확인해보세요!")
                        .pretendard(.captionRegular, color: .gray50)
                }
                Spacer()
                AppImage.banner.image
                    .frame(width: 123, height: 121.81)
            }
            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        }
    }
    
    private var seperator: some View {
        Rectangle()
            .foregroundStyle(AppColor.gray10.color)
            .frame(height: 8)
    }
    
    @ViewBuilder
    private var popularReviews: some View {
        if store.popularReviews.isEmpty == false {
            VStack(spacing: 0) {
                HStack(spacing: 4) {
                    Text("지금 인기 있는 리뷰")
                        .pretendard(.h3Bold, color: .gray90)
                    AppIcon.chatSecondFill.image(width: 20,height: 20,appColor: .orange40)
                    Spacer()
                    NavigationLink(
                        state: UpFeature.MainPath.State.homeReview(
                            HomeReviewFeature.State(category: .popular, currentLocation: store.currentLocation)
                        )
                    ) {
                        HStack(spacing: 4) {
                            Text("더보기")
                                .pretendard(.captionRegular, color: .gray50)
                            AppIcon.arrowRight.image(width: 14, height: 14, appColor: .gray50)
                        }
                    }
                }
                .padding(20)
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(store.popularReviews) { homeReview in
                            reviewCard(homeReview)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    @ViewBuilder
    private var mainRegionReviews: some View {
        if store.mainRegionReviews.isEmpty == false {
            VStack(spacing: 0) {
                HStack(spacing: 4) {
                    Text("우리 동네 최근 리뷰")
                        .pretendard(.h3Bold, color: .gray90)
                    AppIcon.chatSecondFill.image(width: 20,height: 20,appColor: .orange40)
                    Spacer()
                    NavigationLink(
                        state: UpFeature.MainPath.State.homeReview(
                            HomeReviewFeature.State(category: .mainRegion(store.user?.mainRegion.address), currentLocation: store.currentLocation)
                        )
                    ) {
                        HStack(spacing: 4) {
                            Text("더보기")
                                .pretendard(.captionRegular, color: .gray50)
                            AppIcon.arrowRight.image(width: 14, height: 14, appColor: .gray50)
                        }
                    }
                }
                .padding(20)
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(store.mainRegionReviews) { homeReview in
                            reviewCard(homeReview)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    @ViewBuilder
    private var interestedRegionReviews: some View {
        if store.interestedRegionReviews.isEmpty == false { // 관심 동네가 있을 경우에만 노출
            VStack(spacing: 0) {
                HStack(spacing: 4) {
                    Text("관심 동네 최근 리뷰")
                        .pretendard(.h3Bold, color: .gray90)
                    AppIcon.chatSecondFill.image(width: 20,height: 20,appColor: .orange40)
                    Spacer()
                    NavigationLink(
                        state: UpFeature.MainPath.State.homeReview(
                            HomeReviewFeature.State(category: .interestedRegion, currentLocation: store.currentLocation)
                        )
                    ) {
                        HStack(spacing: 4) {
                            Text("더보기")
                                .pretendard(.captionRegular, color: .gray50)
                            AppIcon.arrowRight.image(width: 14, height: 14, appColor: .gray50)
                        }
                    }
                }
                .padding(20)
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(store.interestedRegionReviews) { homeReview in
                            reviewCard(homeReview)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    private func reviewCard(_ homeReview: HomeReview) -> some View {
        NavigationLink(
            state: UpFeature.MainPath.State.detail(
                CompanyDetailFeature.State(
                    companyID: homeReview.company.id
                )
            )
        ) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    Text(homeReview.review.title)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .pretendard(.body1Bold, color: .gray80)
                    Spacer(minLength: 12)
                    HStack(spacing: 4) {
                        AppIcon.starFill.image(width: 24, height: 24, appColor: .seYellow40)
                        Text(homeReview.review.rating.displayText)
                            .pretendard(.body1Bold, color: .gray80)
                    }
                }
                Spacer(minLength: 12)
                Text(homeReview.review.advantagePoint)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .pretendard(.captionRegular, color: .gray70)
                Spacer(minLength: 12)
                HStack {
                    Text(homeReview.company.name)
                        .pretendard(.captionRegular, color: .gray50)
                    Spacer()
                    Text(DateFormatter.reviewCardFormat.string(from: homeReview.review.creationDate))
                        .pretendard(.captionRegular, color: .gray50)
                }
            }
            .padding(20)
        }
        .frame(width: 325, height: 186)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColor.gray20.color)
        }
    }
}

#Preview {
    @Shared(.user) var user = User(
        nickname: "건디",
        mainRegion: Region(
            id: 0,
            address: "서울시 노원구 상계동"
        ),
        interestedRegions: []
    )
    
    NavigationStack {
        HomeView(
            store: Store(
                initialState: HomeFeature.State()
            ) {
                HomeFeature()
            }
        )
    }
}
