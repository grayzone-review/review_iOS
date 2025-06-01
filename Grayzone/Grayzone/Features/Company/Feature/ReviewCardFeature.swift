//
//  ReviewCardFeature.swift
//  Grayzone
//
//  Created by Jun Young Lee on 6/1/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct ReviewCardFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var comments: CommentsWindowFeature.State?
        @Shared var review: Review
    }
    
    enum Action {
        case comments(PresentationAction<CommentsWindowFeature.Action>)
        case reviewCardTapped
        case seeMoreButtonTapped
        case likeButtonTapped
        case commentButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .comments:
                return .none
                
            case .reviewCardTapped:
                state.$review.withLock {
                    $0.isExpanded.toggle()
                }
                return .none
                
            case .seeMoreButtonTapped:
                state.$review.withLock {
                    $0.isExpanded = true
                }
                return .none
                
            case .likeButtonTapped:
                state.$review.withLock {
                    $0.likeCount += $0.isLiked ? -1 : 1
                    $0.isLiked.toggle()
                }
                return .none
                
            case .commentButtonTapped:
                state.comments = CommentsWindowFeature.State(
                    review: state.$review
                )
                return .none
            }
        }
        .ifLet(\.$comments, action: \.comments) {
            CommentsWindowFeature()
        }
    }
}

struct ReivewCardView: View {
    @Bindable var store: StoreOf<ReviewCardFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                header
                rating
            }
            VStack(alignment: .leading, spacing: 4) {
                title
                content
                interaction
            }
        }
        .padding(EdgeInsets(top: 16, leading: 20, bottom: 20, trailing: 20))
        .contentShape(Rectangle())
        .onTapGesture {
            store.send(.reviewCardTapped)
        }
        .sheet(item: $store.scope(state: \.comments, action: \.comments)) { commentsWindowStore in
            CommentsWindowView(store: commentsWindowStore)
        }
    }
    
    private var header: some View {
        HStack(spacing: 8) {
            Text(store.review.nickname)
            divider
            Text(store.review.job)
            divider
            Text(store.review.employmentPeriod)
            divider
            Text("2025. 05 작성") // Date 포맷팅 필요
            Spacer()
        }
        .pretendard(.captionRegular, color: .gray50)
        .frame(maxHeight: 18)
    }
    
    private var divider: some View {
        Divider()
            .background(AppColor.gray20.color)
    }
    
    private var rating: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(store.review.rating.displayText)
                    .pretendard(.h3, color: .gray90)
                StarRatingView(rating: store.review.rating.totalRating)
            }
            
            if store.review.isExpanded {
                ratings
            }
        }
    }
    
    private var totalRating: some View {
        HStack(spacing: 4) {
            Text(store.review.rating.displayText)
                .pretendard(.h3, color: .gray90)
            StarRatingView(rating: store.review.rating.totalRating)
        }
    }
    
    @ViewBuilder
    private var ratings: some View {
        if store.review.isExpanded {
            HStack(alignment: .top) {
                VStack(spacing: 20) {
                    rating("급여", store.review.rating.salary)
                    rating("복지", store.review.rating.welfare)
                    rating("워라벨", store.review.rating.workLifeBalance)
                }
                .frame(width: 118)
                Spacer()
                VStack(spacing: 20) {
                    rating("사내문화", store.review.rating.companyCulture)
                    rating("경영진", store.review.rating.management)
                }
                .frame(width: 118)
            }
            .padding(20)
            .background(AppColor.gray10.color)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColor.gray20.color)
            )
        }
    }
    
    @ViewBuilder
    private func rating(_ item: String, _ rating: Double) -> some View {
        HStack {
            Text(item)
                .pretendard(.captionRegular, color: .gray50)
            Spacer()
            StarRatingView(rating: rating, length: 12, spacing: 2)
        }
    }
    
    private var title: some View {
        Text(store.review.title.withZeroWidthSpaces)
            .pretendard(.h3, color: .gray90)
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            reviewPoint(.advantage)
            reviewPoint(.disadvantage)
            reviewPoint(.managementFeedback)
            seeMoreButton
        }
    }
    
    @ViewBuilder
    private func reviewPoint(_ point: Review.Point) -> some View {
        if store.review.isExpanded || point == .advantage {
            let text = switch point {
            case .advantage:
                store.review.advantagePoint
            case .disadvantage:
                store.review.disadvantagePoint
            case .managementFeedback:
                store.review.managementFeedback
            }
            
            HStack(alignment: .top, spacing: 12) {
                Text(point.keyword)
                    .pretendard(.captionBold, color: point.accentColor)
                    .padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                    .background(point.backgroundColor.color)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                
                Text(text.withZeroWidthSpaces)
                    .pretendard(.body1Regular, color: .gray80)
            }
            .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
            )
        }
    }
    
    @ViewBuilder
    private var seeMoreButton: some View {
        if store.review.isExpanded == false {
            Button {
                store.send(.seeMoreButtonTapped)
            } label: {
                Text("더 보기")
                    .pretendard(.body1Regular, color: .gray50)
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            }
        }
    }
    
    private var interaction: some View {
        HStack(spacing: 8) {
            likeButton
            replyButton
        }
    }
    
    private var likeButton: some View {
        Button {
            store.send(.likeButtonTapped)
        } label: {
            let isLiked = store.review.isLiked
            
            HStack(alignment: .center, spacing: 0) {
                Image(systemName: isLiked ? "heart.fill" : "heart") // 추후 아이콘 변경 필요
                    .foregroundStyle(isLiked ? AppColor.seRed50.color : AppColor.black.color)
                    .frame(width: 44, height: 44)
                Text(String(store.review.likeCount))
                    .pretendard(.body1Bold)
            }
        }
    }
    
    private var replyButton: some View {
        Button {
            store.send(.commentButtonTapped)
        } label: {
            HStack(alignment: .center, spacing: 0) {
                Image(systemName: "bubble") // 추후 아이콘 변경 필요
                    .foregroundStyle(AppColor.black.color)
                    .frame(width: 44, height: 44)
                Text(String(store.review.commentCount))
                    .pretendard(.body1Bold)
            }
        }
    }
}

#Preview {
    ReivewCardView(
        store: Store(
            initialState: ReviewCardFeature.State(
                review: Shared(
                    value: Review(
                        id: 3,
                        rating: Rating(
                            workLifeBalance: 3.5,
                            welfare: 3.5,
                            salary: 3.0,
                            companyCulture: 4.0,
                            management: 3.0
                        ),
                        title: "별로였어요.",
                        advantagePoint: "연봉이 높아요.",
                        disadvantagePoint: "상사가 별로예요.",
                        managementFeedback: "리더십이 부족해요.",
                        nickname: "bob",
                        job: "프론트엔드 개발자",
                        employmentPeriod: "1년 미만",
                        creationDate: .now,
                        likeCount: 3,
                        commentCount: 3,
                        isLiked: true
                    )
                )
            )
        ) {
            ReviewCardFeature()
        }
    )
}
