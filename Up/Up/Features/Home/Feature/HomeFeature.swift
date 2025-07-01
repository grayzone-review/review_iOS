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
        @Presents var destination: Destination.State?
    }
    
    enum Action {
        case makeReviewButtonTapped
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Reducer
    enum Destination {
        case review(ReviewMakingFeature)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .makeReviewButtonTapped:
                state.destination = .review(ReviewMakingFeature.State())
                return .none
                
            case .destination:
                return .none
            }
        }
    }
}

extension HomeFeature.Destination.State: Equatable {}

struct HomeView: View {
    enum ScrollPosition: Int, Identifiable {
        case top
        
        var id: Int {
            rawValue
        }
    }
    
    let store: StoreOf<HomeFeature>
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
                    neighborhoodReviews
                    interestReviews
                }
                .padding(.bottom, 60)
                .id(ScrollPosition.top)
            }
            .scrollPosition(id: $scrollPosition, anchor: .top)
            .scrollIndicators(.hidden)
            .padding(.bottom, 0.5) // 탭바 아래로 반투명 비쳐보임 방지
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
            Text("Up") // 추후 아이콘 결정되면 변경
                .pretendard(.h1, color: .orange40)
        }
    }
    
    private var nicknameButton: some View { // 관련 화면 작업 후 NavigationLink로 래핑
        NavigationLink(
            state: UpFeature.Path.State.activity(
                MyActivityFeature.State(selectedTab: .review)
            )
        ) {
            HStack(spacing: 4) {
                Text("건디님") // 계정 관련 작업 이후 계정 닉네임 받아 사용
                    .pretendard(.body1Bold, color: .orange40)
                AppIcon.arrowRight.image(width: 18, height: 18, appColor: .orange40)
            }
        }
    }
    
    private var searchButton: some View {
        NavigationLink(
            state: UpFeature.Path.State.search(
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
            state: UpFeature.Path.State.search(
                SearchCompanyFeature.State()
            )
        ) {
            ZStack(alignment: .bottomTrailing) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("우리 동네 리뷰가\n궁금하다면?")
                            .pretendard(.body1Bold, color: .white)
                            .multilineTextAlignment(.leading)
                        HStack(spacing: 4) {
                            Text("지금 리뷰 작성하러 가기")
                                .pretendard(.captionSemiBold, color: .white)
                            AppIcon.arrowRight.image(width: 14, height: 14, appColor: .white)
                        }
                        Spacer()
                    }
                    .padding([.top, .leading], 16)
                    
                    Spacer()
                }
                
                AppImage.mapPin.image
                    .frame(width: 68, height: 68)
                    .padding([.bottom, .trailing], 8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 188)
            .background(AppColor.orange40.color)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private var myReviewsBanner: some View {
        NavigationLink(
            state: UpFeature.Path.State.activity(
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
            state: UpFeature.Path.State.activity(
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
    
    private var selectInterestButton: some View {  // 관심 동네가 있을 경우에만 노출
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
    
    private var seperator: some View {
        Rectangle()
            .foregroundStyle(AppColor.gray10.color)
            .frame(height: 8)
    }
    
    private var popularReviews: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                Text("지금 인기 있는 리뷰")
                    .pretendard(.h3, color: .gray90)
                AppIcon.chatSecondFill.image(width: 20,height: 20,appColor: .orange40)
                Spacer()
                HStack(spacing: 4) { // 이후 NavigationLink로 래핑
                    Text("더보기")
                        .pretendard(.captionRegular, color: .gray50)
                    AppIcon.arrowRight.image(width: 14, height: 14, appColor: .gray50)
                }
            }
            .padding(20)
            ScrollView(.horizontal) {
                HStack(spacing: 12) { // 추후 API Response 확정되면 변경
                    reviewCard()
                    reviewCard()
                }
                .padding(.leading, 20)
            }
        }
    }
    
    private var neighborhoodReviews: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                Text("우리 동네 최근 리뷰")
                    .pretendard(.h3, color: .gray90)
                AppIcon.chatSecondFill.image(width: 20,height: 20,appColor: .orange40)
                Spacer()
                HStack(spacing: 4) { // 이후 NavigationLink로 래핑
                    Text("더보기")
                        .pretendard(.captionRegular, color: .gray50)
                    AppIcon.arrowRight.image(width: 14, height: 14, appColor: .gray50)
                }
            }
            .padding(20)
            ScrollView(.horizontal) {
                HStack(spacing: 12) { // 추후 API Response 확정되면 변경
                    reviewCard()
                    reviewCard()
                }
                .padding(.leading, 20)
            }
        }
    }
    
    private var interestReviews: some View { // 관심 동네가 있을 경우에만 노출
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                Text("관심 동네 최근 리뷰")
                    .pretendard(.h3, color: .gray90)
                AppIcon.chatSecondFill.image(width: 20,height: 20,appColor: .orange40)
                Spacer()
                HStack(spacing: 4) { // 이후 NavigationLink로 래핑
                    Text("더보기")
                        .pretendard(.captionRegular, color: .gray50)
                    AppIcon.arrowRight.image(width: 14, height: 14, appColor: .gray50)
                }
            }
            .padding(20)
            ScrollView(.horizontal) {
                HStack(spacing: 12) { // 추후 API Response 확정되면 변경
                    reviewCard()
                    reviewCard()
                }
                .padding(.leading, 20)
            }
        }
    }
    
    private func reviewCard() -> some View {
        NavigationLink(
            state: UpFeature.Path.State.detail(
                CompanyDetailFeature.State(
                    companyID: 1 // 리뷰에 있는 컴퍼니 id 사용
                )
            )
        ) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    Text("현재의 저를 만들어준 공고대행사, 정석으로 생각하며 실행하는 곳")
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .pretendard(.body1Bold, color: .gray80)
                    Spacer(minLength: 12)
                    HStack(spacing: 4) {
                        AppIcon.starFill.image(width: 24, height: 24, appColor: .seYellow40)
                        Text("4.0")
                            .pretendard(.body1Bold, color: .gray80)
                    }
                }
                Spacer(minLength: 12)
                Text("리뷰 내용입니다.\n리뷰 내용입니다.\n리뷰 내용입니다.\n네 줄")
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .pretendard(.captionRegular, color: .gray70)
                Spacer(minLength: 12)
                HStack {
                    Text("스타벅스 석촌역점")
                        .pretendard(.captionRegular, color: .gray50)
                    Spacer()
                    Text("2025. 05 작성")
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
